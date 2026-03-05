#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/status.sh [opciones]

Muestra estado del setup de dotfiles sin modificar nada:
- Host detectado + perfil cargado
- Paquetes según perfil (core/gui)
- Último manifest/backup (si existen)
- Chequeos rápidos de blesh (.blerc)

Opciones:
  --core-only          Modo core (omite GUI)
  --gui                Fuerza incluir GUI
  --json               Salida JSON (stdout) para tooling
  -h, --help           Muestra esta ayuda

Variables de entorno:
  DOTFILES             Ruta al repo (por defecto, carpeta raíz del script)
  DOTFILES_HOST        Override del hostname para perfiles
USAGE
}

GUI_MODE="auto" # auto|on|off
JSON=false

while (($# > 0)); do
  case "$1" in
  --core-only)
    GUI_MODE="off"
    ;;
  --gui)
    GUI_MODE="on"
    ;;
  --json)
    JSON=true
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

info() { [ "$JSON" = "true" ] && return 0; printf '[INFO] %s\n' "$*"; }
warn() { [ "$JSON" = "true" ] && return 0; printf '[WARN] %s\n' "$*" >&2; }

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//"/\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

json_array() {
  local result="["
  local item
  local first=true
  for item in "$@"; do
    if [ "$first" = "true" ]; then
      first=false
    else
      result+=","
    fi
    result+="\"$(json_escape "$item")\""
  done
  result+="]"
  printf '%s' "$result"
}

load_host_profile() {
  local host profile_dir default_profile host_profile

  host="$(resolve_host)"
  profile_dir="$STOW_DIR/dotfiles/.config/dotfiles/hosts"
  default_profile="$profile_dir/default.sh"

  HOME_PKGS=()
  CONFIG_CORE_PKGS=()
  CONFIG_GUI_PKGS=()

  if [ -f "$default_profile" ]; then
    # shellcheck source=/dev/null
    source "$default_profile"
  else
    warn "Perfil default no encontrado: $default_profile"
  fi

  if [ -n "$host" ]; then
    host_profile="$profile_dir/$host.sh"
    if [ -f "$host_profile" ]; then
      info "Perfil host: $host_profile"
      # shellcheck source=/dev/null
      source "$host_profile"
    else
      info "Perfil host: (no existe) $host_profile"
    fi
  else
    warn "No pude determinar hostname"
  fi

  info "Perfil default: $default_profile"
}

main() {
  local host
  host="$(resolve_host || true)"

  info "Repo: $REPO_DIR"
  info "Stow: $STOW_DIR"
  info "Host: ${host:-unknown}"

  if is_wsl; then
    info "Entorno: WSL"
  else
    info "Entorno: Linux"
  fi

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
    *) include_gui=true ;;
    esac
  fi

  local -a home_pkgs=("${HOME_PKGS[@]}")
  local -a config_pkgs=("${CONFIG_CORE_PKGS[@]}")
  if [ "$include_gui" = "true" ]; then
    config_pkgs+=("${CONFIG_GUI_PKGS[@]}")
  fi

  [ "$JSON" = "true" ] || echo
  info "Paquetes -> $HOME: ${home_pkgs[*]}"
  info "Paquetes -> $HOME/.config: dotfiles ${config_pkgs[*]}"

  local have_tmux=false
  local p
  for p in "${home_pkgs[@]}"; do
    if [ "$p" = "tmux" ]; then
      have_tmux=true
      break
    fi
  done

  if [ "$have_tmux" = "true" ]; then
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local tpm="$data_home/tmux/plugins/tpm/tpm"
    if [ -x "$tpm" ]; then
      info "tmux TPM: OK ($tpm)"
    else
      warn "tmux TPM: missing ($tpm)"
    fi
  fi

  [ "$JSON" = "true" ] || echo
  local mf
  if mf="$(latest_manifest 2>/dev/null)"; then
    info "Manifest (latest): $mf"
    local mf_host mf_timestamp mf_backup_abs mf_backup_rel
    manifest_get_string "$mf" host mf_host
    manifest_get_string "$mf" timestamp mf_timestamp
    manifest_get_string "$mf" backup_dir_abs mf_backup_abs
    manifest_get_string "$mf" backup_dir_rel mf_backup_rel
    info "Manifest host: ${mf_host:-}"
    info "Manifest timestamp: ${mf_timestamp:-}"

    if [ -n "$mf_backup_abs" ]; then
      info "Manifest backup: $mf_backup_abs"
    elif [ -n "$mf_backup_rel" ]; then
      info "Manifest backup: $REPO_DIR/${mf_backup_rel}"
    else
      info "Manifest backup: (none)"
    fi
  else
    info "Manifest: (ninguno)"
  fi

  local bk
  if bk="$(latest_backup 2>/dev/null)"; then
    info "Backup (latest): $bk"
  else
    info "Backup: (ninguno)"
  fi

  [ "$JSON" = "true" ] || echo
  local blerc="$HOME/.blerc"
  local blerc_xdg="${XDG_CONFIG_HOME:-$HOME/.config}/blesh/blerc"

  if [ -L "$blerc" ]; then
    info ".blerc: symlink -> $(readlink -- "$blerc" 2>/dev/null || true)"
  elif [ -e "$blerc" ]; then
    warn ".blerc: existe pero no es symlink"
  else
    warn ".blerc: no existe"
  fi

  if [ -r "$blerc_xdg" ]; then
    info "blerc XDG: OK ($blerc_xdg)"
  else
    warn "blerc XDG: no legible ($blerc_xdg)"
  fi

  if [ "$JSON" = "true" ]; then
    local wsl_bool="false"
    is_wsl && wsl_bool="true"

    local tpm_path=""
    local tpm_ok="null"
    if [ "$have_tmux" = "true" ]; then
      local data_home_json="${XDG_DATA_HOME:-$HOME/.local/share}"
      tpm_path="$data_home_json/tmux/plugins/tpm/tpm"
      if [ -x "$tpm_path" ]; then
        tpm_ok="true"
      else
        tpm_ok="false"
      fi
    fi

    local mf_path="" mf_host="" mf_timestamp="" mf_backup=""
    if mf="$(latest_manifest 2>/dev/null)"; then
      mf_path="$mf"
      manifest_get_string "$mf" host mf_host
      manifest_get_string "$mf" timestamp mf_timestamp
      local mf_backup_abs="" mf_backup_rel=""
      manifest_get_string "$mf" backup_dir_abs mf_backup_abs
      manifest_get_string "$mf" backup_dir_rel mf_backup_rel
      if [ -n "$mf_backup_abs" ]; then
        mf_backup="$mf_backup_abs"
      elif [ -n "$mf_backup_rel" ]; then
        mf_backup="$REPO_DIR/$mf_backup_rel"
      fi
    fi

    local bk_path=""
    if bk="$(latest_backup 2>/dev/null)"; then
      bk_path="$bk"
    fi

    local blerc_state="missing" blerc_target=""
    if [ -L "$blerc" ]; then
      blerc_state="symlink"
      blerc_target="$(readlink -- "$blerc" 2>/dev/null || true)"
    elif [ -e "$blerc" ]; then
      blerc_state="file"
    fi

    local blerc_xdg_ok="false"
    [ -r "$blerc_xdg" ] && blerc_xdg_ok="true"

    printf '{"repo":"%s","stow":"%s","host":"%s","wsl":%s,"gui_mode":"%s","home_pkgs":%s,"config_pkgs":%s,"tmux_tpm_path":"%s","tmux_tpm_ok":%s,"manifest_path":"%s","manifest_host":"%s","manifest_timestamp":"%s","manifest_backup":"%s","backup_latest":"%s","blerc_state":"%s","blerc_target":"%s","blerc_xdg_readable":%s}\n' \
      "$(json_escape "$REPO_DIR")" \
      "$(json_escape "$STOW_DIR")" \
      "$(json_escape "${host:-}")" \
      "$wsl_bool" \
      "$(json_escape "$GUI_MODE")" \
      "$(json_array "${home_pkgs[@]}")" \
      "$(json_array "${config_pkgs[@]}")" \
      "$(json_escape "$tpm_path")" \
      "$tpm_ok" \
      "$(json_escape "$mf_path")" \
      "$(json_escape "$mf_host")" \
      "$(json_escape "$mf_timestamp")" \
      "$(json_escape "$mf_backup")" \
      "$(json_escape "$bk_path")" \
      "$(json_escape "$blerc_state")" \
      "$(json_escape "$blerc_target")" \
      "$blerc_xdg_ok"
  fi
}

main
