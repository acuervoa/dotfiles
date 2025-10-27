# Buscar archivo/directorio y abrir
# - Maneja espacios en nombres
# - No peta si no eliges nada
# - Si seleccionas un directorio, te pregunta si quieres cd o abrir en el editor

fo() {
  _req fd fzf bat eza || return 1

  local sel
  sel="$(
    fd --hidden --follow --color=never --exclude .git |
      fzf --ansi \
        --prompt ' abrir > ' \
        --preview='
                  if [ -d {} ]; then
                      eza -la --color=always {}
                  else
                      bat --style=numbers --color=always {} 2>/dev/null | head -500
                  fi
            ' \
        --preview-window=right,70%
  )" || return 0

  [ -z "$sel" ] && return 0

  if [ -d "$sel" ]; then
    printf 'Has elegido un directorio: %s\n' "$sel" >&2
    printf '¿Entrar con "cd" (c) o abrir en editor (e)? [c/e] ' >&2
    read -r ans
    if [ "$ans" = "c" ]; then
      cd -- "$sel" || printf 'No pude hacer cd.\n' >&2
      return
    fi
    "${EDITOR:-nvim}" -- "$sel"
  else
    "${EDITOR:-nvim}" -- "$sel"
  fi

}

# Saltar a un directorio reciente/zoxide
# - Verifica zoxide
# - Evita hacer cd a rutas que ya no existen
# - Maneja rutas con espacios
cdf() {
  _req zoxide fzf eza || return 1

  local dir
  dir="$(
    zoxide query -l |
      sed '/^$/d' |
      sort -u |
      fzf --ansi \
        --prompt ' cd > ' \
        --preview 'eza -la --color=always {}' \
        --preview-window=right,60%
  )" || return 0

  [ -z "$dir" ] && return 0

  if [ ! -d "$dir" ]; then
    printf 'Ruta elegida ya no existe: %s\n' "$dir" >&2
    return 1
  fi

  cd -- "$dir" || printf 'No pude hacer cd.\n' >&2
}

# mkdir + cd
take() {
  if [ -z "$1" ]; then
    printf "Uso: take <directorio>\n" >&2
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" || return
}

# Extraer archivos comprimidos con una sola orden
extract() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    printf "Uso: extract <archivo>\n" >&2
    return 1
  fi
  case "$1" in
  *.tar.bz2) tar xjf "$1" ;;
  *.tar.gz) tar xzf "$1" ;;
  *.tar.xz) tar xJf "$1" ;;
  *.tar) tar xf "$1" ;;
  *.tbz2) tar xjf "$1" ;;
  *.tgz) tar xzf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.gz) gunzip "$1" ;;
  *.xz) unxz "$1" ;;
  *.zip) unzip "$1" ;;
  *.7z) 7z x "$1" ;;
  *)
    printf "'%s' no es un formato soportado\n" "$1" >&2
    return 2
    ;;
  esac
}

# Copiar salida de un comando al clipboard del sistema (Wayland/X11)
# - Soporta pipe ("echo foo | cb") y argumento ("cb foo")
cb() {
  local input
  if [ -t 0 ]; then
    input="$*"
    [ -z "$input" ] && {
      printf 'Uso: echo "texto" | cb   o   cb "texto"\n' >&2
      return 1
    }
  else
    input="$(cat)"
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$input" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$input" | xclip -selection clipboard
  else
    printf "No hay wl-copy ni xclip instalados\n" >&2
    return 1
  fi
}
