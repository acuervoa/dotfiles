#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"
tmp_runtime="$tmp_home/runtime"
tmp_output="$tmp_home/session.log"
tmp_bin="$tmp_home/bin"
trap 'rm -rf "$tmp_home"' EXIT

mkdir -p "$tmp_home/.config" "$tmp_home/state" "$tmp_home/cache" "$tmp_runtime" "$tmp_bin"
chmod 700 "$tmp_runtime"

# Keep this contract test independent from whether Atuin is installed on the
# host. The real .bashrc only needs its init output to define the owner.
cat >"$tmp_bin/atuin" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '__atuin_history() { :; }'
EOF
chmod +x "$tmp_bin/atuin"

ln -s "$repo_root/stow/bash/.profile" "$tmp_home/.profile"
ln -s "$repo_root/stow/bash/.bash_lib" "$tmp_home/.bash_lib"
ln -s "$repo_root/stow/bash/.bash_aliases" "$tmp_home/.bash_aliases"
ln -s "$repo_root/stow/blesh/.config/blesh" "$tmp_home/.config/blesh"
ln -s "$repo_root/stow/blesh/.blerc" "$tmp_home/.blerc"

printf '%s\n' \
  'printf "BLE_FUNCTION=%s\\n" "$(declare -F ble-bind >/dev/null && echo yes || echo no)"' \
  'ble-bind -P | grep -E "C-r.*__atuin_history|C-t.*_bash_keymap_files|M-c.*_bash_keymap_dirs"' \
  'bleopt complete_auto_delay' \
  'exit' >"$tmp_home/input"

if ! timeout 20 script -qefc "env PATH='$tmp_bin:/usr/bin:/bin' HOME='$tmp_home' XDG_STATE_HOME='$tmp_home/state' XDG_CACHE_HOME='$tmp_home/cache' XDG_RUNTIME_DIR='$tmp_runtime' TERM=xterm-256color bash --noprofile --rcfile '$repo_root/stow/bash/.bashrc' -i" "$tmp_output" <"$tmp_home/input" >/dev/null 2>&1; then
  printf '%s\n' 'FAIL: la sesión interactiva de ble.sh terminó con error' >&2
  sed -n '1,240p' "$tmp_output" >&2
  exit 1
fi

assert_output() {
  local pattern="$1" message="$2"
  if ! grep -Fq "$pattern" "$tmp_output"; then
    printf 'FAIL: %s (buscando: %s)\n' "$message" "$pattern" >&2
    sed -n '1,240p' "$tmp_output" >&2
    exit 1
  fi
}

assert_output 'BLE_FUNCTION=yes' 'ble.sh no se inicializó'
assert_output 'C-r' 'binding C-r ausente'
assert_output '__atuin_history' 'owner de Atuin ausente'
assert_output '_bash_keymap_files' 'selector de archivos ausente'
assert_output '_bash_keymap_dirs' 'selector de directorios ausente'
assert_output 'complete_auto_delay' 'opción de autocompletado ausente'
assert_output '120' 'retardo de autocompletado inesperado'
test "$(grep -cE '^[[:space:]]*ble-attach[[:space:]]*$' "$repo_root/stow/bash/.bashrc")" -eq 1
grep -Fq 'ble-import integration/fzf-completion' "$repo_root/stow/blesh/.config/blesh/blerc"
grep -Fq 'ble-import integration/fzf-key-bindings' "$repo_root/stow/blesh/.config/blesh/blerc"

printf '%s\n' 'PASS: ble.sh, Atuin y FZF comparten ownership sin colisiones'
