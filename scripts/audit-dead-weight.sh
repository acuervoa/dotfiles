#!/usr/bin/env bash
# Escanea los paquetes explícitos de pacman en busca de candidatos a peso muerto:
# sin referencia en stow/, sin proceso corriendo, sin reverse-deps.
# No es un veredicto final — filtra ruido para revisión manual antes de eliminar nada.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stow_dir="$repo_root/stow"

# Paquetes que se saben legítimos aunque no dejen rastro en stow/ (toolbox, deps de build, etc.)
# Editar esta lista cuando una revisión manual confirme que un flag es falso positivo.
allowlist=(
  base base-devel linux linux-firmware linux-headers intel-ucode grub efibootmgr
  man-db man-pages man-pages-es
)

is_allowlisted() {
  local pkg="$1"
  for a in "${allowlist[@]}"; do
    [[ "$pkg" == "$a" ]] && return 0
  done
  return 1
}

# Dump único del historial de atuin — mucho más rápido que consultarlo por paquete.
atuin_cache="$(mktemp)"
trap 'rm -f "$atuin_cache"' EXIT
if command -v atuin >/dev/null 2>&1; then
  atuin history list --cmd-only 2>/dev/null | awk '{print $1}' | sort -u >"$atuin_cache"
fi

printf '%s\n' '# Candidatos a peso muerto — revisar a mano antes de eliminar'
printf '%s\n' '# PKG|binarios|refs_stow|reverse_deps|proceso_activo|en_historial|señal'
printf '%s\n' '# señal: cuantas más "no", más sospechoso. Nunca actúes solo por esto.'

pacman -Qeq | sort | while read -r pkg; do
  is_allowlisted "$pkg" && continue

  # Binarios que provee el paquete (solo /usr/bin, /usr/local/bin)
  bins="$(pacman -Ql "$pkg" 2>/dev/null | awk '{print $2}' | { grep -E '/(usr/)?(local/)?bin/[^/]+$' || true; } | xargs -r -n1 basename 2>/dev/null | sort -u | tr '\n' ',' | sed 's/,$//')"
  [[ -z "$bins" ]] && bins="$pkg"

  # ¿Referenciado en stow/ (nombre de paquete o alguno de sus binarios)? Un solo grep con alternancia.
  refs_stow="no"
  pattern="\b(${pkg}|$(printf '%s' "$bins" | sed 's/,/|/g'))\b"
  if grep -rlqE -- "$pattern" "$stow_dir" 2>/dev/null; then
    refs_stow="si"
  fi

  # Reverse deps reales (algo que dependa de este paquete)
  reverse_deps="no"
  pacman -Qi "$pkg" 2>/dev/null | grep -q "^Requerido por.*: [^N]" && reverse_deps="si" || true

  # Proceso corriendo ahora mismo con alguno de los binarios
  proceso="no"
  IFS=',' read -ra bin_arr <<<"$bins"
  for b in "${bin_arr[@]}"; do
    [[ -z "$b" ]] && continue
    pgrep -x "$b" >/dev/null 2>&1 && {
      proceso="si($b)"
      break
    } || true
  done

  # ¿Alguno de los binarios aparece en el historial real de comandos (atuin)?
  en_historial="no"
  if [[ -s "$atuin_cache" ]]; then
    IFS=',' read -ra bin_arr <<<"$bins"
    for b in "${bin_arr[@]}"; do
      [[ -z "$b" ]] && continue
      if grep -qxF "$b" "$atuin_cache" 2>/dev/null; then
        en_historial="si($b)"
        break
      fi
    done
  else
    en_historial="sin_datos"
  fi

  # Señal agregada: cuenta cuántos "no" hay entre las 4 señales
  no_count=0
  [[ "$refs_stow" == "no" ]] && no_count=$((no_count + 1))
  [[ "$reverse_deps" == "no" ]] && no_count=$((no_count + 1))
  [[ "$proceso" == "no" ]] && no_count=$((no_count + 1))
  [[ "$en_historial" == "no" ]] && no_count=$((no_count + 1))

  if ((no_count == 4)); then
    senal="ALTA"
  elif ((no_count == 3)); then
    senal="media"
  else
    continue # con 0-2 "no", no es candidato — se omite del reporte
  fi

  printf 'PKG|%s|%s|%s|%s|%s|%s|%s\n' "$pkg" "$bins" "$refs_stow" "$reverse_deps" "$proceso" "$en_historial" "$senal"
done
