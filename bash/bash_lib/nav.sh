# nav.sh - navegación de ficheros y clipboard

## Buscar archivo/directorio y abrir
# - No peta si no eliges nada
# - Soporta rutas con espacios.
# - Excluye basura típica (node_modules, vendor, dist, .venv...) para no saturar fzf.
# - Si eliges un directorio: te deja elegir cd o abrir en editor.
# cmd fo  Buscar archivo/directorio con fd+fzf y abrir (bat/eza)
fo() {
  _req fd fzf bat eza || return 1

  local root="${1:-.}"
  local -a fd_args
  local sel

  # Excludes por defecto, ampliables via FD_DEFAULT_EXCLUDES
  local -a excludes
  if [ -n "${FD_DEFAULT_EXCLUDES:-}" ]; then
    # shellcheck disable=SC2206
    excludes=($FD_DEFAULT_EXCLUDES)
  else
    excludes=(.git node_modules vendor .venv dist build target .cache)
  fi

  fd_args=(--hidden --follow --colo=never)
  local ex
  for ex in "${excludes[@]}"; do
    fd_args+=(--exclude "$ex")
  done

  sel="$(
    fd "${fd_args[@]}" . "$root" 2>/dev/null |
      fzf --prompt=' fo > ' --preview='
        if [ -d "{}" ]; then
          if command -v eza >/dev/null 2>&1; then
            eza -la --color=always "{}"
          else
            \ls -lah {}
          fi 
        else 
          if command -v bat >/dev/null 2>&1; then
            bat --style=numbers --color=always "{}" 2>/dev/null || file {}
          else
            file {}
          fi
        fi
      ' --preview-window=right,60%
  )" || return 0

  [ -z "$sel" ] && return 0

  if [ -d "$sel" ]; then
    printf 'Directorio seleccionado: %s\n' "$sel" >&2
    if _confirm '¿cd a este directorio? [y/N] '; then
      cd -- "$sel" || printf 'No pude hacer cd.\n' >&2
    fi
  else
    _edit_at "$sel"
  fi

}

# saltar a un directorio reciente (zoxide)
# - Usa zoxide query -l.
# - Filtra vacíos y duplicados.
# - Preview con eza correctamente quoteado.
# - Verifica que el destino sigue existiendo.
# @cmd cdf  Buscar directorio con fd+fzf y hacer cd
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
# @cmd take   mkdir -p y cd al directorio
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
# @cmd extract  Descomprimir un archivo según su extensión
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
# @cmd cb   Copiar texto al portapapeles (stdin, arg o fichero)
cb() {
  local data

  if [ "$#" -eq 0 ]; then
    data="$(cat)"
  elif [ "$#" -eq 1 ] && [ -f "$1" ]; then
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
