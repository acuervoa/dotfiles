#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/bootstrap.sh [opciones]

Crea symlinks de los paquetes `stow/` hacia `$HOME` y `$HOME/.config`.
Si hay conflictos (targets existentes que no son symlinks), los mueve a
`.backups/<TIMESTAMP>/` antes de crear enlaces.

Opciones:
  -n, --dry-run          Muestra acciones sin modificar nada
  -y, --yes              No pedir confirmación (modo no-interactivo)
  --core-only            Instala solo paquetes no-GUI (útil en WSL/servers)
  --gui                  Fuerza incluir paquetes GUI (desktop)
  --init-submodules      Inicializa submódulos (git) si aplica
  --skip-tmux-plugins     No instala plugins de tmux via TPM
  --strict-tmux-plugins   Falla si TPM no puede instalar plugins
  -h, --help             Muestra esta ayuda

Variables de entorno:
  DOTFILES               Ruta al repo (por defecto, carpeta raíz del script)

Ejemplos:
  scripts/bootstrap.sh --dry-run
  scripts/bootstrap.sh --core-only
USAGE
}

DRY_RUN=false
ASSUME_YES=false
INIT_SUBMODULES=false
GUI_MODE="auto" # auto|on|off
BACKUP_NEEDED=false
SKIP_TMUX_PLUGINS=false
STRICT_TMUX_PLUGINS=false

while (($# > 0)); do
  case "$1" in
  -n | --dry-run)
    DRY_RUN=true
    ;;
  -y | --yes)
    ASSUME_YES=true
    ;;
  --core-only)
    GUI_MODE="off"
    ;;
  --gui)
    GUI_MODE="on"
    ;;
  --init-submodules)
    INIT_SUBMODULES=true
    ;;
  --skip-tmux-plugins)
    SKIP_TMUX_PLUGINS=true
    ;;
  --strict-tmux-plugins)
    STRICT_TMUX_PLUGINS=true
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs
ensure_compat_links

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"
MANIFEST_FILE="$MANIFEST_DIR/$TIMESTAMP.manifest"

# Paquetes por defecto (se pueden sobreescribir por perfil de host)
HOME_PKGS=()
CONFIG_CORE_PKGS=()
CONFIG_GUI_PKGS=()
CONFIG_PKGS=()

resolve_host() {
  if [ -n "${DOTFILES_HOST:-}" ]; then
    printf '%s' "$DOTFILES_HOST"
    return 0
  fi

  if command -v hostname >/dev/null 2>&1; then
    hostname -s 2>/dev/null || hostname 2>/dev/null || true
  fi
}

load_host_profile() {
  local host profile_dir default_profile host_profile

  host="$(resolve_host)"
  profile_dir="$STOW_DIR/dotfiles/.config/dotfiles/hosts"
  default_profile="$profile_dir/default.sh"

  if [ -f "$default_profile" ]; then
    # shellcheck source=/dev/null
    source "$default_profile"
  else
    warn "Perfil default no encontrado: $default_profile"
  fi

  if [ -n "$host" ]; then
    host_profile="$profile_dir/$host.sh"
    if [ -f "$host_profile" ]; then
      info "Cargando perfil de host: $host"
      # shellcheck source=/dev/null
      source "$host_profile"
    else
      info "Sin perfil especifico para host '$host' (uso default)"
    fi
  else
    warn "No pude determinar hostname; uso perfil default"
  fi

  CONFIG_PKGS=("${CONFIG_CORE_PKGS[@]}" "${CONFIG_GUI_PKGS[@]}")
}

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

action() {
  local kind="$1"
  shift

  if [ "$DRY_RUN" = "true" ]; then
    printf '[DRY-RUN][%s] %s\n' "$kind" "$*"
  else
    printf '[%s] %s\n' "$kind" "$*"
  fi
}

run_cmd() {
  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi
  "$@"
}

maybe_install_tmux_plugins() {
  [ "$SKIP_TMUX_PLUGINS" = "true" ] && return 0

  if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux no está instalado; omito instalación de plugins."
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    warn "git no está instalado; TPM no podrá clonar plugins."
    return 0
  fi

  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local plugins_dir="$data_home/tmux/plugins"
  if [ -L "$plugins_dir" ]; then
    printf '[ERROR] %s es un symlink; no instalo plugins para evitar escribir en un path inesperado.\n' "$plugins_dir" >&2
    return 1
  fi
  if [ ! -d "$plugins_dir" ]; then
    run_cmd mkdir -p "$plugins_dir"
  fi

  local tpm="$plugins_dir/tpm/tpm"
  local install="$plugins_dir/tpm/bin/install_plugins"

  if [ ! -x "$tpm" ]; then
    if [ -e "$plugins_dir/tpm" ]; then
      printf '[ERROR] Existe %s pero no parece un TPM válido (no ejecutable). Elíminalo y reintenta.\n' "$plugins_dir/tpm" >&2
      return 1
    fi

    action TMUX "Clonando TPM -> $plugins_dir/tpm"
    if [ "$DRY_RUN" = "true" ]; then
      return 0
    fi
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$plugins_dir/tpm"
  fi

  if [ ! -x "$tpm" ] || [ ! -x "$install" ]; then
    printf '[ERROR] TPM no quedó instalado correctamente en %s\n' "$plugins_dir/tpm" >&2
    return 1
  fi

  action TMUX "Instalando plugins via TPM (TMUX_PLUGIN_MANAGER_PATH=$plugins_dir)"
  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi

  tmux start-server
  tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugins_dir/"
  local out ec
  out="$("$install" 2>&1)"
  ec=$?
  printf '%s\n' "$out"

  if [ "$ec" -ne 0 ]; then
    local -a failed_plugins=()
    local p
    while IFS= read -r p; do
      [ -n "$p" ] && failed_plugins+=("$p")
    done < <(printf '%s\n' "$out" | awk '/download fail/{gsub(/"/,"",$1); print $1}')

    warn "TPM falló instalando uno o más plugins (posible causa: git auth/HTTPS con GitHub)."
    if [ "${#failed_plugins[@]}" -gt 0 ]; then
      warn "Plugins fallidos: ${failed_plugins[*]}"
    fi
    warn "Puedes reintentar: $install"
    warn "O saltarlo: bootstrap --skip-tmux-plugins"
    [ "$STRICT_TMUX_PLUGINS" = "true" ] && return 1
  fi
}

cleanup_legacy_links() {
  # Remove legacy stow-managed symlinks that are no longer part of the repo.
  # This prevents "stow -S" from leaving stale links around on upgrades.
  local -a paths=(
    "$HOME/.vim"
    "$HOME/.vimrc"
    "$HOME/.tmux/plugins"
  )

  local p target rel
  for p in "${paths[@]}"; do
    [ -L "$p" ] || continue
    target="$(readlink -- "$p" 2>/dev/null || true)"

    case "$target" in
    *"/stow/vim/"* | *"/stow/tmux/.tmux/plugins"*)
      BACKUP_NEEDED=true

      action BACKUP "mkdir -p $BACKUP_DIR"
      run_cmd mkdir -p "$BACKUP_DIR"

      rel="${p#$HOME/}"
      action MOVE "Moviendo symlink legacy $p -> $BACKUP_DIR/$rel"
      run_cmd mkdir -p "$BACKUP_DIR/$(dirname -- "$rel")"
      run_cmd mv -- "$p" "$BACKUP_DIR/$rel"
      ;;
    esac
  done
}

confirm() {
  local msg="${1:-¿Continuar? [y/N] }" ans

  if [ "$ASSUME_YES" = "true" ]; then
    return 0
  fi

  printf '%s' "$msg" >&2
  read -r ans
  case "$ans" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

require_cmd() {
  local c
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      printf '[ERROR] Este script requiere %s instalado.\n' "$c" >&2
      exit 1
    fi
  done
}

is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] && return 0
  [ -r /proc/version ] && grep -qiE 'microsoft|wsl' /proc/version && return 0
  return 1
}

write_manifest() {
  action MANIFEST "Escribiendo manifest: $MANIFEST_FILE"

  run_cmd mkdir -p "$MANIFEST_DIR"

  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi

  local host
  host="$(resolve_host || true)"

  cat >"$MANIFEST_FILE" <<EOF
# dotfiles manifest (auto-generado)
# timestamp: $TIMESTAMP

timestamp="$TIMESTAMP"
host="${host:-}"
home_pkgs=(${HOME_PKGS[*]})
config_pkgs=(${CONFIG_PKGS[*]})
backup_needed="pending"
backup_dir_rel=""
backup_dir_abs=""
backup_dir_state_rel=""
exit_code=""
EOF
}

finalize_manifest() {
  local ec="${1:-0}"

  [ "$DRY_RUN" = "true" ] && return 0
  [ -f "$MANIFEST_FILE" ] || return 0

  {
    echo
    echo "# bootstrap result"
    echo "exit_code=\"$ec\""
    if [ "$BACKUP_NEEDED" = "true" ]; then
      echo "backup_needed=\"true\""
      echo "backup_dir_rel=\".backups/$TIMESTAMP\""
      echo "backup_dir_abs=\"$BACKUP_DIR\""
      echo "backup_dir_state_rel=\"$TIMESTAMP\""
    else
      echo "backup_needed=\"false\""
      echo "backup_dir_rel=\"\""
      echo "backup_dir_abs=\"\""
      echo "backup_dir_state_rel=\"\""
    fi
  } >>"$MANIFEST_FILE"
}

maybe_init_submodules() {
  if [ "$INIT_SUBMODULES" != "true" ]; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "git no está instalado; no puedo inicializar submódulos."
    return 0
  fi

  if [ ! -f "$REPO_DIR/.gitmodules" ]; then
    warn "No existe .gitmodules; omitiendo init de submódulos."
    return 0
  fi

  action GIT "git submodule update --init --recursive"
  run_cmd git -C "$REPO_DIR" submodule update --init --recursive
}

handle_conflicts() {
  local pkg="$1"
  local target_dir="$2"

  info "Comprobando conflictos para '$pkg' en $target_dir..."

  local conflicts
  conflicts="$(
    stow -d "$STOW_DIR" -t "$target_dir" -nS "$pkg" 2>&1 |
      grep -E 'existing target is not (a symlink|owned by stow|a directory|a link nor a directory):' || true
  )"

  if [ -z "$conflicts" ]; then
    return 0
  fi

  BACKUP_NEEDED=true

  warn "Conflictos detectados para '$pkg'. Se creará un backup en $BACKUP_DIR"
  action BACKUP "mkdir -p $BACKUP_DIR"
  run_cmd mkdir -p "$BACKUP_DIR"

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    local file_path
    file_path="$line"
    file_path="${file_path#*CONFLICT: existing target is not a symlink: }"
    file_path="${file_path#*existing target is not owned by stow: }"
    file_path="${file_path#*existing target is not a directory: }"
    file_path="${file_path#*existing target is not a link nor a directory: }"

    local full_path="$target_dir/$file_path"

    action MOVE "Moviendo $full_path -> $BACKUP_DIR/$file_path"
    run_cmd mkdir -p "$BACKUP_DIR/$(dirname -- "$file_path")"
    run_cmd mv -- "$full_path" "$BACKUP_DIR/$file_path"
  done <<<"$conflicts"
}

main() {
  require_cmd stow

  [ -d "$REPO_DIR" ] || {
    printf '[ERROR] Repo no encontrado en: %s\n' "$REPO_DIR" >&2
    exit 1
  }
  [ -d "$STOW_DIR" ] || {
    printf '[ERROR] Directorio stow no encontrado en: %s\n' "$STOW_DIR" >&2
    exit 1
  }

  load_host_profile

  local include_gui=true
  if is_wsl; then
    include_gui=false
    if [ "$GUI_MODE" = "on" ]; then
      warn "WSL2 detectado; omitiendo GUI aunque se haya pedido --gui."
    fi
  else
    case "$GUI_MODE" in
    off) include_gui=false ;;
    on | auto) include_gui=true ;;
    *)
      warn "GUI_MODE inválido: $GUI_MODE (uso auto)"
      include_gui=true
      ;;
    esac
  fi

  # Flags siguen pudiendo ajustar el modo GUI.
  CONFIG_PKGS=("${CONFIG_CORE_PKGS[@]}")
  if [ "$include_gui" = "true" ]; then
    CONFIG_PKGS+=("${CONFIG_GUI_PKGS[@]}")
  fi

  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"
  info "Timestamp: $TIMESTAMP"
  if [ "$DRY_RUN" = "true" ]; then
    info "Modo simulación activo (no se aplicarán cambios)"
  fi

  echo
  info "Paquetes -> $HOME: ${HOME_PKGS[*]}"
  info "Paquetes -> $HOME/.config: ${CONFIG_PKGS[*]}"
  info "Paquete -> $HOME/.config: dotfiles (perfiles de host)"
  echo

  if [ "$DRY_RUN" != "true" ]; then
    warn "Esto modificará $HOME (symlinks) y puede mover ficheros a $BACKUP_DIR"
    confirm '¿Continuar? [y/N] ' || {
      info 'Operación cancelada.'
      exit 0
    }
  fi

  maybe_init_submodules
  write_manifest
  trap 'finalize_manifest "$?"' EXIT

  cleanup_legacy_links

  # Procesar paquetes de $HOME
  local installed_tmux=false
  local pkg
  for pkg in "${HOME_PKGS[@]}"; do
    handle_conflicts "$pkg" "$HOME"
    action STOW "Instalando '$pkg' en $HOME"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -S "$pkg"
    if [ "$pkg" = "tmux" ]; then
      installed_tmux=true
    fi
  done

  if [ "$installed_tmux" = "true" ]; then
    maybe_install_tmux_plugins
  fi

  # Paquete meta (perfiles de host). Se instala siempre.
  if [ -d "$STOW_DIR/dotfiles" ]; then
    handle_conflicts "dotfiles" "$HOME"
    action STOW "Instalando 'dotfiles' (bajo $HOME/.config)"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -S dotfiles
  else
    warn "Paquete stow inexistente (omito): dotfiles"
  fi

  # Procesar paquetes que viven bajo $HOME/.config.
  # Nota: los paquetes en stow/* suelen incluir el prefijo `.config/`, así que
  # el target correcto para stow es $HOME (no $HOME/.config), para evitar acabar
  # con rutas tipo ~/.config/.config/<pkg>.
  run_cmd mkdir -p "$HOME/.config"
  for pkg in "${CONFIG_PKGS[@]}"; do
    handle_conflicts "$pkg" "$HOME"
    action STOW "Instalando '$pkg' (bajo $HOME/.config)"
    run_cmd stow -d "$STOW_DIR" -t "$HOME" -S "$pkg"
  done

  echo
  info "Bootstrap completado."
  info "Manifest: $MANIFEST_FILE"
  if [ "$BACKUP_NEEDED" = "true" ]; then
    if [ "$DRY_RUN" = "true" ]; then
      info "Backup: se crearía en $BACKUP_DIR"
    else
      info "Backup: $BACKUP_DIR"
    fi
  else
    info "Backup: no fue necesario"
  fi
}

main
