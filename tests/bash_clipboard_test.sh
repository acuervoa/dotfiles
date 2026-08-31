#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

for file in "$repo_root"/stow/bash/.bashrc \
  "$repo_root"/stow/bash/.bash_profile \
  "$repo_root"/stow/bash/.profile \
  "$repo_root"/stow/bash/.bash_aliases \
  "$repo_root"/stow/bash/.bash_functions \
  "$repo_root"/stow/bash/.bash_lib/*.sh; do
  bash -n "$file" || fail "sintaxis: $file"
done
pass "sintaxis Bash"

source "$repo_root/stow/bash/.bash_lib/core.sh"
source "$repo_root/stow/bash/.bash_lib/nav.sh"

export PATH="$tmp_dir:$PATH"
export DISPLAY=:test
export WAYLAND_DISPLAY=wayland-test
export XDG_RUNTIME_DIR="$tmp_dir/runtime"
mkdir -p "$XDG_RUNTIME_DIR"

cat >"$tmp_dir/xclip" <<'EOF'
#!/usr/bin/env bash
printf 'xclip %s\n' "$*" >>"${CLIP_TEST_LOG:?}"
cat
EOF
cat >"$tmp_dir/wl-copy" <<'EOF'
#!/usr/bin/env bash
printf 'wl-copy\n' >>"${CLIP_TEST_LOG:?}"
cat
EOF
cat >"$tmp_dir/wl-paste" <<'EOF'
#!/usr/bin/env bash
printf 'wl-paste\n' >>"${CLIP_TEST_LOG:?}"
EOF
chmod +x "$tmp_dir/xclip" "$tmp_dir/wl-copy" "$tmp_dir/wl-paste"
export CLIP_TEST_LOG="$tmp_dir/commands.log"

_clipboard_command copy || fail "el resolver de clipboard no está implementado"

if [[ "${_CLIPBOARD_CMD[*]}" != "xclip -selection clipboard" ]]; then
  fail "X11 debe seleccionar xclip, obtuvo: ${_CLIPBOARD_CMD[*]}"
fi
pass "X11 selecciona xclip"

rm -f -- "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
export WAYLAND_DISPLAY=wayland-missing
_clipboard_command copy || fail "X11 debe funcionar con socket Wayland ausente"
[[ "${_CLIPBOARD_CMD[*]}" == "xclip -selection clipboard" ]] ||
  fail "un Wayland inválido no debe seleccionar wl-copy"
pass "Wayland inválido hace fallback a X11"

_clipboard_command paste || fail "resolver de paste falló"
[[ "${_CLIPBOARD_CMD[*]}" == "xclip -selection clipboard -o" ]] ||
  fail "X11 paste debe usar xclip -o"
pass "X11 paste selecciona xclip -o"

old_path="$PATH"
PATH="$tmp_dir"
old_display="$DISPLAY"
old_wayland_display="$WAYLAND_DISPLAY"
unset DISPLAY WAYLAND_DISPLAY
if _clipboard_command copy 2>"$tmp_dir/no-backend.err"; then
  fail "el resolver debería fallar sin backend"
fi
[[ "$(<"$tmp_dir/no-backend.err")" == *"no hay backend disponible"* ]] ||
  fail "falta diagnóstico de backend ausente"
PATH="$old_path"
DISPLAY="$old_display"
WAYLAND_DISPLAY="$old_wayland_display"
pass "ausencia de backend produce diagnóstico"

pbcopy() {
  _clipboard_command copy || return 1
  _clipboard_copy
}

pbpaste() {
  _clipboard_command paste || return 1
  "${_CLIPBOARD_CMD[@]}"
}

printf 'public-copy' | pbcopy || fail "pbcopy falló"
grep -q '^xclip -selection clipboard$' "$CLIP_TEST_LOG" ||
  fail "pbcopy no delegó en xclip"
pass "pbcopy delega en el resolver"

rm -f -- "$CLIP_TEST_LOG"
printf 'cb-copy' | cb || fail "cb falló"
grep -q '^xclip -selection clipboard$' "$CLIP_TEST_LOG" ||
  fail "cb no delegó en el resolver"
pass "cb delega en el resolver"
