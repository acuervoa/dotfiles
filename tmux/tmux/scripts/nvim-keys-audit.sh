#!/usr/bin/env bash
set -euo pipefail

has() { command -v "$1" >/dev/null 2>&1; }
has tmux || { echo "tmux no encontrado"; exit 1; }

declare -a ROWS=()
check() {
  local key="$1"
  if tmux list-keys -T root 2>/dev/null | grep -E -- "-n[[:space:]]+$key( |$)" >/dev/null; then
    ROWS+=("root|-n $key|captura sin prefijo → Neovim no lo verá")
  fi
}

for k in F10 M-S-Left M-S-Right M-S-Up M-S-Down C-h C-j C-k C-l C-\\; do
  check "$k"
done

printf "%-12s | %-16s | %s\n" "KEY-TABLE" "BINDING" "PROBLEMA"
printf "%s\n" "-------------------------------------------------------------"
if [ ${#ROWS[@]} -eq 0 ]; then
  echo "OK: no se detectan binds con -n de teclas críticas."
else
  for row in "${ROWS[@]}"; do
    IFS='|' read -r t b msg <<<"$row"
    printf "%-12s | %-16s | %s\n" "$t" "$b" "$msg"
  done
fi
echo
cat <<'EOF'
Sugerencias:
  • Quita '-n' (obliga prefijo) o usa if-shell para detectar (n)vim y hacer passthrough.
  • F10: pásalo a Neovim para DAP, o usa <leader>dO/dI/dU como alternativa.
  • Alt+Shift+Flechas: si los usas en Neovim para resize, deja pasar en panes con (n)vim.
EOF

