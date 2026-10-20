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

error() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

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
  arch) printf '%s' "$REPO_DIR/pkglist-arch.txt" ;;
  debian) printf '%s' "$REPO_DIR/pkglist-debian.txt" ;;
  fedora) printf '%s' "$REPO_DIR/pkglist-fedora.txt" ;;
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

install_one() {
  local distro="$1" pkg="$2"

  case "$distro" in
  arch) sudo pacman -S --needed -- "$pkg" ;;
  debian) sudo apt-get install -y -- "$pkg" ;;
  fedora) sudo dnf install -y -- "$pkg" ;;
  *) return 1 ;;
  esac
}

# Neovim: la config exige >= 0.11 y apt (Ubuntu 24.04 = 0.9.x) se queda corto,
# así que en Debian/Ubuntu se instala el tarball oficial en ~/.local.
NVIM_VERSION="v0.12.6"

install_neovim_tarball() {
  local arch
  case "$(uname -m)" in
  x86_64) arch="x86_64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    warn "Arquitectura sin tarball de Neovim: $(uname -m)"
    return 1
    ;;
  esac

  local opt_dir="$HOME/.local/opt" bin_dir="$HOME/.local/bin"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${arch}.tar.gz"
  local tmp
  tmp="$(mktemp -d)"

  info "Instalando Neovim ${NVIM_VERSION} (${arch}) en $opt_dir/nvim"
  if ! curl -fsSL "$url" -o "$tmp/nvim.tar.gz" || ! tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"; then
    rm -rf "$tmp"
    warn "No se pudo descargar/extraer Neovim desde $url"
    return 1
  fi

  mkdir -p "$opt_dir" "$bin_dir"
  rm -rf "$opt_dir/nvim"
  mv "$tmp/nvim-linux-${arch}" "$opt_dir/nvim"
  ln -sfn "$opt_dir/nvim/bin/nvim" "$bin_dir/nvim"
  rm -rf "$tmp"
}

# nvim-treesitter (rama main) compila los parsers con el CLI `tree-sitter`,
# que no está en apt: se instala el binario oficial en ~/.local/bin.
TREE_SITTER_VERSION="v0.26.9"

install_tree_sitter_cli() {
  local arch
  case "$(uname -m)" in
  x86_64) arch="x64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    warn "Arquitectura sin binario de tree-sitter: $(uname -m)"
    return 1
    ;;
  esac

  local bin_dir="$HOME/.local/bin"
  local url="https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-${arch}.gz"
  local tmp
  tmp="$(mktemp)"

  info "Instalando tree-sitter CLI ${TREE_SITTER_VERSION} (${arch}) en $bin_dir"
  if ! curl -fsSL "$url" | gunzip >"$tmp"; then
    rm -f "$tmp"
    warn "No se pudo descargar tree-sitter desde $url"
    return 1
  fi

  mkdir -p "$bin_dir"
  install -m 0755 "$tmp" "$bin_dir/tree-sitter"
  rm -f "$tmp"
}

# Debian/Ubuntu instalan `bat` como `batcat` y `fd` como `fdfind`.
link_debian_renamed_bins() {
  local bin_dir="$HOME/.local/bin" pair real alias_name
  mkdir -p "$bin_dir"
  for pair in batcat:bat fdfind:fd; do
    real="${pair%%:*}"
    alias_name="${pair##*:}"
    if command -v "$real" >/dev/null 2>&1 && ! command -v "$alias_name" >/dev/null 2>&1; then
      ln -s "$(command -v "$real")" "$bin_dir/$alias_name"
      info "Enlace $bin_dir/$alias_name -> $real"
    fi
  done
}

main() {
  local include_gui=false dry_run=false

  # Default selection is core-only.
  while (($# > 0)); do
    case "$1" in
    --core) ;; # already default
    --gui) include_gui=true ;;
    --all) include_gui=true ;;
    --dry-run) dry_run=true ;;
    -y | --yes) ASSUME_YES=true ;;
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

  if ! confirm "¿Instalar ${#packages[@]} paquetes? [y/N] "; then
    info "Instalación cancelada."
    exit 0
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

  if [ "$distro" = "debian" ]; then
    link_debian_renamed_bins
    install_neovim_tarball || warn "Neovim no instalado: la config de nvim no arrancará."
    install_tree_sitter_cli || warn "tree-sitter no instalado: Neovim no podrá compilar parsers."
  fi

  info "Instalación de dependencias completada."
}

main "$@"
