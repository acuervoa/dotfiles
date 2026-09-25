#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ai_file="$repo_root/stow/bash/.bash_lib/ai.sh"

test -f "$ai_file"
bash -n "$ai_file"
for name in sbs sbsb sbl sbe sbo sbclose afdp afdb ai; do
  count="$(rg -c "^${name}[[:space:]]*\(\)" "$ai_file" || true)"
  test "$count" -eq 1
done
rg -q 'tools/ai-session.sh' "$ai_file"
rg -q 'tools/sbo-close-open-candidates.sh' "$ai_file"
rg -q 'tools/sbclose.sh' "$ai_file"
rg -q 'sbl \[--note <ruta>\]' "$ai_file"
rg -q 'tools/ai-flow\.sh\)" start' "$ai_file"
rg -q 'tools/ai-flow\.sh\)" cycle' "$ai_file"
rg -q 'tools/ai-flow\.sh\)" distill-run' "$ai_file"
rg -q 'tools/ai-flow\.sh\)" distill-apply' "$ai_file"
rg -q 'tools/ai-flow\.sh\)" distill-apply --draft' "$ai_file"
! rg -q '(^|[[:space:]])ai-flow([[:space:]]|$)' "$ai_file"
printf 'PASS: ai.sh delega el flujo de sesiones a SimpleBrain/tools\n'
