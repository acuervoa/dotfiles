#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: install_deps.sh [opciones]

Instala dependencias para este repo (multi-distro) leyendo un pkglist por distro.

Opciones:
  --core        Instala paquetes core (default)
  --gui         Incluye paquetes de entorno gráfico (desktop)
  --all         Equivalente a --core --gui
  --dry-run     Muestra lo que haría, sin instalar
  -y, --yes     No pedir confirmación
  -h, --help    Muestra esta ayuda

Notas:
- En WSL2, por defecto se instala solo --core (sin GUI).
- Algunas distros nombran binarios distinto (p.ej. `fd` vs `fdfind`, `bat` vs `batcat`).
USAGE
}

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] && return 0
  [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version && return 0
  return 1
}

detect_distro() {
  if [ -f /etc/arch-release ]; then
    printf 'arch'
    return 0
  fi

  if [ -f /etc/debian_version ]; then
    printf 'debian'
    return 0
  fi

  if [ -f /etc/redhat-release ] || [ -f /etc/fedora-release ]; then
    printf 'fedora'
    return 0
  fi

  return 1
}

pkglist_for() {
  local distro="$1"
  case "$distro" in
  arch) printf '%s' "$REPO_ROOT/pkglist-arch.txt" ;;
  debian) printf '%s' "$REPO_ROOT/pkglist-debian.txt" ;;
  fedora) printf '%s' "$REPO_ROOT/pkglist-fedora.txt" ;;
  *) return 1 ;;
  esac
}

read_pkglist() {
  local file="$1" include_gui="$2"
  local section="core"
  local -a out=()

  [ -f "$file" ] || error "No se encontró el fichero '$file'."

  while IFS= read -r line; do
    case "$line" in
    '' | \#*)
      case "$line" in
      \#\ *GUI*) section="gui" ;;
      \#\ *Core*) section="core" ;;
      esac
      continue
      ;;
    esac

    case "$section" in
    core) out+=("$line") ;;
    gui)
      if [ "$include_gui" = "true" ]; then
        out+=("$line")
      fi
      ;;
    esac
  done <"$file"

  printf '%s\n' "${out[@]}"
}

confirm() {
  local msg="$1" ans
  printf '%s' "$msg" >&2
  read -r ans
  case "$ans" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

install_one() {
  local distro="$1" pkg="$2"

  case "$distro" in
  arch) sudo pacman -S --needed -- "$pkg" ;;
  debian) sudo apt-get install -y -- "$pkg" ;;
  fedora) sudo dnf install -y -- "$pkg" ;;
  *) return 1 ;;
  esac
}

main() {
  local include_gui=false dry_run=false assume_yes=false

  # Default selection is core-only.
  while (($# > 0)); do
    case "$1" in
    --core) ;; # already default
    --gui) include_gui=true ;;
    --all) include_gui=true ;;
    --dry-run) dry_run=true ;;
    -y | --yes) assume_yes=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      error "Opción no reconocida: $1"
      ;;
    esac
    shift
  done

  local distro
  distro="$(detect_distro)" || error "Distro no soportada (Arch, Debian/Ubuntu, Fedora)."

  local wsl=false
  if is_wsl; then
    wsl=true
    include_gui=false
  fi

  local pkglist
  pkglist="$(pkglist_for "$distro")" || error "No hay pkglist para distro: $distro"

  info "Distro: $distro"
  $wsl && info "WSL2 detectado: modo core-only"
  info "Pkglist: $pkglist"
  if [ "$include_gui" = "true" ]; then
    info "Incluyendo GUI"
  else
    info "Solo core"
  fi

  local -a packages=()
  mapfile -t packages < <(read_pkglist "$pkglist" "$include_gui")

  if [ "${#packages[@]}" -eq 0 ]; then
    error "El pkglist no contiene paquetes instalables."
  fi

  if [ "$dry_run" = "true" ]; then
    info "DRY-RUN: instalaría (${#packages[@]}): ${packages[*]}"
    exit 0
  fi

  case "$distro" in
  debian)
    info "Actualizando índices (apt-get update)..."
    sudo apt-get update
    ;;
  esac

  if [ "$assume_yes" != "true" ]; then
    if ! confirm "¿Instalar ${#packages[@]} paquetes? [y/N] "; then
      info "Instalación cancelada."
      exit 0
    fi
  fi

  local -a failed=()
  local p
  for p in "${packages[@]}"; do
    info "Instalando: $p"
    if ! install_one "$distro" "$p"; then
      warn "No se pudo instalar: $p"
      failed+=("$p")
    fi
  done

  if [ "${#failed[@]}" -gt 0 ]; then
    warn "Paquetes fallidos (${#failed[@]}): ${failed[*]}"
    warn "Puedes editar $pkglist o instalar esos paquetes manualmente."
  fi

  info "Instalación de dependencias completada."
}

main "$@"
