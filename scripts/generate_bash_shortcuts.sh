#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalog="$repo_root/stow/bash/.bash_grammar"
output="$repo_root/BASH_SHORTCUTS.md"
tmp_output="$(mktemp)"
trap 'rm -f -- "$tmp_output"' EXIT

[ -r "$catalog" ] || {
  printf 'No se puede leer el catálogo: %s\n' "$catalog" >&2
  exit 1
}

awk -F '\t' '
  NR == 1 { if ($0 != "name\tgroup\trisk\tmicro\tdescription\texample") exit 2; next }
  $1 ~ /^#/ || NF == 0 { next }
  NF != 6 { exit 3 }
  { print }
' "$catalog" >/dev/null || {
  printf 'Catálogo inválido: %s\n' "$catalog" >&2
  exit 1
}

render_row() {
  local name="$1" group="$2" risk="$3" micro="$4" description="$5" example="$6"
  local marker
  case "$risk" in
  safe) marker='✅ seguro' ;;
  confirm) marker='⚠️ confirmación' ;;
  mutating) marker='🔴 mutación' ;;
  esac
  printf '| `%s` | %s | %s | `%s` |\n' "$name" "$description" "$marker" "$example"
}

render_group() {
  local group="$1" title="$2" line name row_group risk micro description example
  printf '## %s\n\n' "$title"
  printf '| Comando | Descripción | Riesgo | Ejemplo |\n| --- | --- | --- | --- |\n'
  while IFS=$'\t' read -r name row_group risk micro description example; do
    [ "$row_group" = "$group" ] || continue
    render_row "$name" "$row_group" "$risk" "$micro" "$description" "$example"
  done < <(tail -n +2 "$catalog" | sort -t $'\t' -k2,2 -k1,1)
  printf '\n'
}

{
  printf '# Bash shortcuts · gramática operativa\n\n'
  printf 'Catálogo generado desde `stow/bash/.bash_grammar`.\n\n'
  printf 'Riesgo: ✅ seguro · ⚠️ confirmación · 🔴 mutación.\n\n'

  printf '## Micro-atajos\n\n'
  printf '| Tecla | Acción | Grupo |\n| --- | --- | --- |\n'
  while IFS=$'\t' read -r name group risk micro description example; do
    [ "$micro" = yes ] || continue
    printf '| `%s` | %s | `%s` |\n' "$name" "$description" "$group"
  done < <(tail -n +2 "$catalog" | sort -t $'\t' -k1,1)
  printf '\n'

  render_group git 'Git (`g*`)'
  render_group docker 'Docker (`d*`)'
  render_group php 'PHP/Laravel (`p*`)'
  render_group runtime 'Runtime/QA (`r*`)'
  render_group ai 'AI Flow (`af*`)'
  render_group simplebrain 'SimpleBrain (`sb*`)'
  render_group navigation 'Navegación'
  render_group system 'Sistema'
  render_group utility 'Utilidad'
} >"$tmp_output"

mv -- "$tmp_output" "$output"
printf 'Generado: %s\n' "$output" >&2
