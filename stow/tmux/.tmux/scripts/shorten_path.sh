#!/usr/bin/env bash
set -euo pipefail

p="${1:-$PWD}"       # path de entrada
w="${2:-50}"         # ancho final fijo (padding/truncado)
threshold=20         # a partir de esta longitud se abrevia

# Normaliza HOME -> ~
p="${p/#$HOME/~}"

# --- helpers ---
join_by_slash() { local IFS='/'; printf "%s" "$*"; }

shorten_keep_last_two() {
  local path="$1"
  local lead=""
  [[ "$path" == /* ]] && lead="/"
  local body="${path#/}"             # quita slash inicial solo para split

  IFS='/' read -r -a parts <<< "$body"
  local n="${#parts[@]}"

  # 0..2 componentes: no abreviar
  if (( n <= 2 )); then
    [[ -n "$lead" ]] && printf "/%s" "$(join_by_slash "${parts[@]}")" || printf "%s" "$body"
    return
  fi

  local out=""
  for (( i=0; i<n; i++ )); do
    local comp="${parts[i]}"
    [[ -z "$comp" ]] && continue
    if (( i < n-2 )); then
      # intermedios abreviados (salvo '~' que se mantiene)
      if [[ "$comp" == "~" ]]; then
        out+="/~"
      else
        out+="/${comp:0:1}"
      fi
    else
      # últimos dos completos
      out+="/${comp}"
    fi
  done

  # reaplica slash inicial si el original era absoluto
  [[ -n "$lead" ]] && printf "%s" "$out" || printf "%s" "${out#/}"
}

collapse_to_ellipsis_last() {
  # deja solo ".../basename"
  local path="$1"
  local base; base="$(basename -- "$path")"
  printf ".../%s" "$base"
}

# --- lógica principal ---
# Si no supera el umbral, respeta el path tal cual (con padding/truncado final)
if (( ${#p} <= threshold )); then
  printf "%.${w}s" "$p"
  exit 0
fi

# 1) Abrevia manteniendo los dos últimos directorios completos
abbr="$(shorten_keep_last_two "$p")"

# 2) Si aún no cabe en w: colapsa a .../ultimo
if (( ${#abbr} > w )); then
  abbr="$(collapse_to_ellipsis_last "$p")"
fi

# 3) Salida de ancho fijo (pad/trunc)
printf "%.${w}s" "$abbr"

