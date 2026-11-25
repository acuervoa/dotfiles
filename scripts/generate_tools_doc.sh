#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit="$repo_root/scripts/audit-application-ownership.sh"
output="$repo_root/TOOLS.md"
tmp_output="$(mktemp)"
trap 'rm -f -- "$tmp_output"' EXIT

[ -x "$audit" ] || {
  printf 'No se puede ejecutar el audit: %s\n' "$audit" >&2
  exit 1
}

[ -f "$repo_root/docs/wl.md" ] || {
  printf 'Falta docs/wl.md, enlazado desde TOOLS.md: %s\n' "$repo_root/docs/wl.md" >&2
  exit 1
}

{
  printf '# Herramientas instaladas\n\n'
  printf 'Generado desde `scripts/audit-application-ownership.sh` — no editar a mano.\n\n'
  printf 'Disponibilidad: ✅ instalada · 🔴 falta el binario.\n\n'
  printf '| Herramienta | Binario | Uso | Config versionada |\n| --- | --- | --- | --- |\n'

  # shellcheck disable=SC2034 # config_state no se usa aquí, ya viene en el campo "available"
  while IFS='|' read -r record name binary config config_state available context; do
    [ "$record" = APP ] || continue
    marker=$([ "$available" = available ] && printf '✅' || printf '🔴')
    printf '| **%s** %s | `%s` | %s | `%s` |\n' "$name" "$marker" "$binary" "$context" "$config"
  done < <("$audit")

  printf '\n## Ownership por capacidad\n\n'
  printf 'Una sola herramienta por capacidad — ver `docs/audits/2026-09-02-application-integration.md` para el razonamiento.\n\n'
  printf '| Capacidad | Owner |\n| --- | --- |\n'
  while IFS='|' read -r record capability owner; do
    [ "$record" = CAPABILITY ] || continue
    printf '| %s | **%s** |\n' "$capability" "$owner"
  done < <("$audit")

  printf '\n## Herramientas propias\n\n'
  printf '| Herramienta | Ubicación | Uso | Contrato |\n| --- | --- | --- | --- |\n'
  printf '%s\n' "| **wl** | \`stow/bin/.local/bin/wl\` | registro de trabajo por equipo (git + JSONL) | [docs/wl.md](docs/wl.md) |"
} >"$tmp_output"

mv -- "$tmp_output" "$output"
printf 'Generado: %s\n' "$output" >&2
