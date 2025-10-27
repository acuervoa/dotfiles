# Buscar archivo/directorio y abrir
# - No peta si no eliges nada
# - Soporta rutas con espacios.
# - Excluye basura típica (node_modules, vendor, dist, .venv...) para no saturar fzf.
# - Si eliges un directorio: te deja elegir cd o abrir en editor.

fo() {
  _req fd fzf bat eza || return 1

  local sel
  sel="$(
    fd --hidden --follow --color=never \
      --exclude .git \
      --exclude node_modules \
      --exclude vendor \
      --exclude .venv \
      --exclude dist \
      --exclude target |
      fzf --ansi \
        --prompt ' abrir > ' \
        --preview='
                  if [ -d "{}" ]; then
                      eza -la --color=always "{}"
                  else
                      bat --style=numbers --color=always "{}" 2>/dev/null | head -500
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
    _edit_at "$sel"
  else
    _edit_at "$sel"
  fi

}

# saltar a un directorio reciente (zoxide)
# - Usa zoxide query -l.
# - Filtra vacíos y duplicados.
# - Preview con eza correctamente quoteado.
# - Verifica que el destino sigue existiendo.
cdf() {
  _req zoxide fzf eza || return 1

  local dir
  dir="$(
    zoxide query -l 2>/dev/null |
      sed '/^$/d' |
      awk '!seen[0]++' |
      fzf --ansi \
        --prompt ' cd > ' \
        --preview 'eza -la --color=always "{}"' \
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
# - Crea (mkdir -p) y entra.
# - Usa cd -- para rutas raras con espacios o guiones iniciales.
take() {
  if [ -z "$1" ]; then
    printf "Uso: take <directorio>\n" >&2
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" || return
}

# descomprimir un archivo según su extensión
# - Comprueba que el archivo existe.
# - Comprueba que la herramienta necesaria está instalada antes de llamar.
extract() {
  local file="$1"
  if [ -z "$1" ] || [ ! -f "$1" ]; then
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
    printf "'%s' no es un formato soportado\n" "$1" >&2
    return 2
    ;;
  esac
}

# copiar texto al portapapeles
#
# - Acepta stdin (echo foo | cb) o argumentos (cb foo bar baz).
# - Soporta wl-copy, xclip y pbcopy.
# - No añade salto de línea adicional.
cb() {
  local data

  if [ -t 0 ]; then
    data="$(cat)"
  elif [ $# -eq 1 ] && [ -f "$1" ]; then
    data="$(cat -- "$1")"
  else
    data="$*"
    if [ -z "$data" ]; then
      printf 'Uso:\techo "texto" | cb\n\tcb "texto libre"\n\tcb fichero.txt\n' >&2
      return 1
    fi
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$data" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$data" | xclip -selection clipboard
  elif command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$data" | pbcopy
  else
    printf "No hay wl-copy, xclip ni pbcopy instalados\n" >&2
    return 1
  fi
}
