#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/stow/i3/.config/i3/config"
script="$repo_root/stow/i3/.config/i3/scripts/confirm_kill.sh"

test -x "$script"
bash -n "$script"
grep -Fq 'bindsym $mod+q exec --no-startup-id ~/.config/i3/scripts/confirm_kill.sh' "$config"
grep -Fq -- '-no-custom' "$script"
grep -Fq -- '-mesg' "$script"
grep -Fq 'i3-msg kill' "$script"

fake_bin="$(mktemp -d)"
trap 'rm -rf "$fake_bin"' EXIT
cat >"$fake_bin/rofi" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${ROFI_TEST_CHOICE:-Cancelar}"
EOF
cat >"$fake_bin/i3-msg" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >"${I3_TEST_OUTPUT:?}"
EOF
chmod +x "$fake_bin/rofi" "$fake_bin/i3-msg"

output="$fake_bin/output"
PATH="$fake_bin:$PATH" ROFI_TEST_CHOICE=Cancelar I3_TEST_OUTPUT="$output" "$script"
test ! -e "$output"
PATH="$fake_bin:$PATH" ROFI_TEST_CHOICE=Cerrar I3_TEST_OUTPUT="$output" "$script"
grep -Fxq 'kill' "$output"

printf '%s\n' 'PASS: diálogo de cierre i3 definido para teclado'
