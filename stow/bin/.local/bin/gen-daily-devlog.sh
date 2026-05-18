#!/usr/bin/env bash
set -euo pipefail

VAULT="${VAULT:-$HOME/Vaults/SimpleBrain}"
DAILY_DIR="$VAULT/DAILY"
TEMPLATE="${TEMPLATE:-$VAULT/00_HOME/Plantillas/T - Daily Dual Devlog.md}"
GIT_LOG_SCRIPT="$HOME/.local/bin/devlog-git-today.sh"

d="$(date +%F)"
out="$DAILY_DIR/$d.md"

mkdir -p "$DAILY_DIR"

if [[ -f "$out" ]]; then exit 0; fi

# Get git log
git_log_content=$(mktemp)
if [[ -x "$GIT_LOG_SCRIPT" ]]; then
    "$GIT_LOG_SCRIPT" > "$git_log_content"
fi

if [[ ! -s "$git_log_content" ]]; then
    echo "Sin actividad de git detectada." > "$git_log_content"
fi

# Generate session_id
session_id=$(( (RANDOM % 900000) + 100000 ))

if [[ -f "$TEMPLATE" ]]; then
    # Use python for safer replacement
    python3 -c "
import os
template_path = '$TEMPLATE'
git_log_path = '$git_log_content'
date_str = '$d'
session_id = '$session_id'
output_path = '$out'

with open(template_path, 'r') as f:
    content = f.read()

with open(git_log_path, 'r') as f:
    git_log = f.read()

content = content.replace('{{date}}', date_str)
content = content.replace('{{git_log}}', git_log)
content = content.replace('{{session_id}}', session_id)
content = content.replace('{{project_name}}', 'N/A')
content = content.replace('{{current_focus}}', 'N/A')
content = content.replace('{{next_action}}', 'ver #next')

with open(output_path, 'w') as f:
    f.write(content)
"
else
    # Fallback
    {
        echo "---"
        echo "type: daily"
        echo "created: $d"
        echo "tags: [daily, devlog]"
        echo "---"
        echo ""
        echo "# DAILY - $d"
        echo ""
        echo "## Git log"
        cat "$git_log_content"
        echo ""
        echo "## Próxima Acción"
        echo "- [ ] #next "
    } > "$out"
fi

rm "$git_log_content"
