# nav.sh - navegación de ficheros y clipboard
# shellcheck shell=bash

# Quote seguro para inyectar valores en un comando que ejecutará /bin/sh -c
# Devuelve el argumento entre comillas simples, escapando comillas simples internas.
_dotfiles_shq() {
  # usage: _dotfiles_shq "string"
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

## Buscar archivo/directorio y abrir
# - No peta si no eliges nada
# - Soporta rutas con espacios.
# - Excluye basura típica (node_modules, vendor, dist, .venv...) para no saturar fzf.
# - Si eliges un directorio: te deja elegir cd o abrir en editor.
# @cmd fo  Buscar archivo/directorio con fd+fzf y abrir (bat/eza)
# Opciones:
#   FO_DEFAULT_ROOT (default .)
#   FO_EXCLUDES (lista separada por espacios; se añade a los excludes base)
#   FO_AUTO_CD=1 para no pedir confirm al cd
#   FO_FOLLOW=1 para seguir symlinks (default 0)
#   FO_MAX_DEPTH=N (default 8; 0 sin límite)

dotfiles_excludes_nul() {
  # prints NUL-separated excludes loaded from config + env overrides
  local cfg="${DOTFILES_IGNORE_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/ignore}"
  local -a out=()

  if [ -f "$cfg" ]; then
    # strip comments/blank lines
    mapfile -t out < <(grep -vE '^[[:space:]]*(#|$)' "$cfg" || true)
  fi

  # Compatibility: allow space-separated env adds
  if [ -n "${FD_DEFAULT_EXCLUDES:-}" ]; then
    local -a tmp=()
    read -r -a tmp <<<"${FD_DEFAULT_EXCLUDES}"
    out+=("${tmp[@]}")
  fi

  # Per-invocation excludes (space-separated) can be passed in $1
  if [ -n "${1:-}" ]; then
    local -a tmp=()
    read -r -a tmp <<<"${1}"
    out+=("${tmp[@]}")
  fi

  printf '%s\0' "${out[@]}"
}

fo() {
  _req fd fzf || return 1

  local root="${FO_DEFAULT_ROOT:-${1:-.}}"
  local auto_cd="${FO_AUTO_CD:-0}"

  local preview_cwd preview_cmd
  preview_cwd="$(pwd -P)"
  preview_cmd="fo-preview \"{}\" $(_dotfiles_shq "$preview_cwd")"

  local -a excludes fd_args
  mapfile -d '' -t excludes < <(dotfiles_excludes_nul "${FO_EXCLUDES:-}")

  fd_args=(--hidden --color=never)
  [ "${FO_FOLLOW:-0}" = "1" ] && fd_args+=(--follow)

  local max_depth="${FO_MAX_DEPTH:-8}"
  [ "$max_depth" != "0" ] && fd_args+=(--max-depth "$max_depth")

  local ex
  for ex in "${excludes[@]}"; do
    fd_args+=(--exclude "$ex")
  done

  local sel
  sel="$(
    fd "${fd_args[@]}" . "$root" 2>/dev/null |
      sed 's|^\./||' |
      FZF_DEFAULT_OPTS='' FZF_DEFAULT_COMMAND='' fzf \
        --prompt=' fo > ' \
        --preview="$preview_cmd" \
        --preview-window=right,60%
  )" || return 0

  [ -z "$sel" ] && return 0

  if [ -d "$sel" ]; then
    printf 'Directorio seleccionado: %s\n' "$sel" >&2
    if [ "$auto_cd" != "1" ]; then
      if ! _confirm '¿Cambiar a este directorio? [y/N] '; then
        return 0
      fi
    fi
    cd -- "$sel" || printf 'No pude hacer cd.\n' >&2
  else
    _edit_at "$sel"
  fi
}

# saltar a un directorio reciente (zoxide)
# @cmd cdf  Ir a un directorio (zoxide+fzf si esta disponible; si no, fd+fzf)
# Opciones (fallback fd):
#   CDF_EXCLUDES (lista separada por espacios; se añade a excludes base)
#   CDF_FOLLOW=1 para seguir symlinks (default 0)
#   CDF_MAX_DEPTH=N (default 8; 0 sin límite)
cdf() {
  _req fzf || return 1

  local root="${1:-.}"
  local dir

  local preview_cwd preview_cmd
  preview_cwd="$(pwd -P)"
  preview_cmd="fo-preview \"{}\" $(_dotfiles_shq "$preview_cwd")"

  if command -v zoxide >/dev/null 2>&1; then
    dir="$(
      zoxide query -l 2>/dev/null |
        FZF_DEFAULT_OPTS='' FZF_DEFAULT_COMMAND='' fzf \
          --prompt=' cdf(zoxide) > ' \
          --preview="$preview_cmd" \
          --preview-window=right,60%
    )" || return 0
  else
    _req fd || return 1

    local -a excludes fd_args
    mapfile -d '' -t excludes < <(dotfiles_excludes_nul "${CDF_EXCLUDES:-}")

    fd_args=(--type d --hidden --color=never)
    [ "${CDF_FOLLOW:-0}" = "1" ] && fd_args+=(--follow)

    local max_depth="${CDF_MAX_DEPTH:-8}"
    [ "$max_depth" != "0" ] && fd_args+=(--max-depth "$max_depth")

    local ex
    for ex in "${excludes[@]}"; do
      fd_args+=(--exclude "$ex")
    done

    dir="$(
      fd "${fd_args[@]}" . "$root" 2>/dev/null |
        sed 's|^\./||' |
        FZF_DEFAULT_OPTS='' FZF_DEFAULT_COMMAND='' fzf \
          --prompt=' cdf(fd) > ' \
          --preview="$preview_cmd" \
          --preview-window=right,60%
    )" || return 0
  fi

  [ -z "$dir" ] && return 0
  [ ! -d "$dir" ] && {
    printf 'Ruta elegida ya no existe: %s\n' "$dir" >&2
    return 1
  }

  cd -- "$dir" || printf 'No pude hacer cd.\n' >&2
}

# mkdir + cd
# @cmd take   mkdir -p y cd al directorio
take() {
  if [ -z "${1:-}" ]; then
    printf "Uso: take <directorio>\n" >&2
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" || return
}

# descomprimir un archivo según su extensión
# @cmd extract  Descomprimir un archivo según su extensión
extract() {
  local file="${1:-}"
  if [ -z "$file" ] || [ ! -f "$file" ]; then
    printf "Uso: extract <archivo>\n" >&2
    return 1
  fi

  case "$file" in
  *.tar.bz2 | *.tbz2)
    _req tar || return 1
    tar xjf -- "$file"
    ;;
  *.tar.gz | *.tgz)
    _req tar || return 1
    tar xzf -- "$file"
    ;;
  *.tar.xz)
    _req tar || return 1
    tar xJf -- "$file"
    ;;
  *.tar)
    _req tar || return 1
    tar xf -- "$file"
    ;;
  *.bz2)
    _req bunzip2 || return 1
    bunzip2 -- "$file"
    ;;
  *.gz)
    _req gunzip || return 1
    gunzip -- "$file"
    ;;
  *.xz)
    _req unxz || return 1
    unxz -- "$file"
    ;;
  *.zip)
    _req unzip || return 1
    unzip -- "$file"
    ;;
  *.7z)
    _req 7z || return 1
    7z x -- "$file"
    ;;
  *.tar.zst | *.tzst)
    _req tar unzstd || { _req tar zstd || return 1; }
    if command -v unzstd >/dev/null 2>&1; then
      tar --use-compress-program=unzstd -xf -- "$file"
    else
      tar --use-compress-program=zstd -xf -- "$file"
    fi
    ;;
  *)
    printf "'%s' no es un formato soportado\n" "$file" >&2
    return 2
    ;;
  esac
}

# copiar texto al portapapeles
# @cmd cb   Copiar texto al portapapeles (stdin, texto o contenido de archivos)
cb() {
  local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  local wayland_sock=""

  if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    wayland_sock="$runtime_dir/$WAYLAND_DISPLAY"
  else
    [ -S "$runtime_dir/wayland-0" ] && wayland_sock="$runtime_dir/wayland-0"
  fi

  local -a clip_cmd=()

  if command -v wl-copy >/dev/null 2>&1 && [ -n "$wayland_sock" ] && [ -S "$wayland_sock" ]; then
    clip_cmd=(wl-copy)
  elif [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
    clip_cmd=(xclip -selection clipboard)
  elif [ -n "${DISPLAY:-}" ] && command -v xsel >/dev/null 2>&1; then
    clip_cmd=(xsel --clipboard --input)
  elif command -v pbcopy >/dev/null 2>&1; then
    clip_cmd=(pbcopy)
  else
    if [ -t 1 ]; then
      local data
      if [ "$#" -eq 0 ]; then
        data=$(cat)
      else
        data="$*"
      fi
      printf '\e]52;c;%s\a' "$(printf '%s' "$data" | base64 | tr -d '\n')"
      return 0
    fi
    printf "cb: no hay portapapeles disponible (Wayland/X11/macOS). Instala wl-clipboard o xclip/xsel, o ejecuta bajo sesión gráfica.\n" >&2
    return 1
  fi

  if [ "$#" -eq 0 ]; then
    "${clip_cmd[@]}"
    return $?
  fi

  local all_files=1 f
  for f in "$@"; do
    [ -f "$f" ] || {
      all_files=0
      break
    }
  done

  if [ "$all_files" -eq 1 ]; then
    cat -- "$@" | "${clip_cmd[@]}"
  else
    if [ "$#" -eq 1 ]; then
      printf '%s' "$1" | "${clip_cmd[@]}"
    else
      printf '%s' "$*" | "${clip_cmd[@]}"
    fi
  fi
}

# @cmd proj Ir a un proyecto (fzf sobre PROJECTS_ROOT)
proj() {
  _req fzf || return 1

  local root="${PROJECTS_ROOT:-$HOME/Workspace}"

  if [ -n "${1:-}" ]; then
    root="$1"
  fi

  if [ ! -d "$root" ]; then
    printf 'Directorio de proyectos no existe: %s\n' "$root" >&2
    return 1
  fi

  local projects
  projects="$(
    find "$root" -mindepth 1 -maxdepth 3 -type d -name '.git' -print 2>/dev/null |
      sed "s|^$root/||; s|/.git$||" |
      sort -u
  )"

  if [ -z "$projects" ]; then
    printf 'No se han encontrado proyectos (directorios con .git) bajo %s\n' "$root" >&2
    return 1
  fi

  local rel
  rel="$(
    printf '%s\n' "$projects" |
      fzf --prompt=' proj > ' \
        --preview='
            target="'"$root"'/"{}
            if [ -d "$target" ]; then
              if command -v eza >/dev/null 2>&1; then
                eza -lah --color=always -- "$target"
              else
                \ls -lah -- "$target"
              fi
            fi
          ' \
        --preview-window=right,60%
  )" || return 0

  [ -z "$rel" ] && return 0

  local dest="$root/$rel"

  if [ ! -d "$dest" ]; then
    printf 'Destino ya no existe: %s\n' "$dest" >&2
    return 1
  fi

  builtin cd -- "$dest" || {
    printf 'No pude hacer cd a %s\n' "$dest" >&2
    return 1
  }

  if command -v zoxide >/dev/null 2>&1; then
    zoxide add "$dest" >/dev/null 2>&1 || true
  fi
}

tproj() {
  local name="${1:-}"

  if [ -z "$name" ]; then
    printf 'Uso: tproj <nombre-proyecto>\n' >&2
    return 1
  fi

  local dir="$HOME/Workspace/$name"

  if [ ! -d "$dir" ]; then
    printf 'No existe el directorio %s\n' "$dir" >&2
    return 1
  fi

  local session="proj-$name"

  if tmux has-session -t "$session" 2>/dev/null; then
    if [ -n "${TMUX-}" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session"
    fi
    return 0
  fi

  tmux new-session -d -s "$session" -c "$dir" -n dev
  tmux send-keys -t "$session:dev" 'nvim .' C-m

  tmux new-window -t "$session" -n shell -c "$dir"
  tmux new-window -t "$session" -n logs -c "$dir"
  tmux send-keys -t "$session:logs" 'docker compose logs -f php' C-m

  if [ -n "${TMUX-}" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}
