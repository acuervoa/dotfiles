#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# El gate sólo se puede evaluar sobre un checkout reproducible.
test -z "$(git status --porcelain)"
git diff --check

# Los sistemas estabilizados no pueden cambiar silenciosamente dentro de esta
# línea de trabajo. Se compara contra la rama de integración si existe.
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  protected_changes="$(git diff --name-only origin/main...HEAD -- \
    stow/tmux/.tmux.conf stow/i3/.config/i3/config)"
  test -z "$protected_changes"
fi

test -f docs/audits/2026-09-16-application-friction-review.md
grep -Fq 'PENDIENTE' docs/audits/2026-09-16-application-friction-review.md

bash scripts/check.sh
bash scripts/check-desktop-configs.sh --static
bash tests/application_ownership_test.sh
bash tests/rofi_workflow_contract_test.sh
bash tests/blesh_integration_test.sh
bash tests/clipboard_ownership_test.sh
bash tests/terminal_feedback_contract_test.sh
bash tests/application_workflow_contract_test.sh
bash tests/application_grammar_test.sh

printf '%s\n' 'PASS: release gate de integración de aplicativos'
