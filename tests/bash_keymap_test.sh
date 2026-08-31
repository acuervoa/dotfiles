#!/usr/bin/env bash
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $- != *i* ]]; then
  script_path="$repo_root/tests/$(basename "$0")"
  exec bash --noprofile --norc -ic 'source "$1"' bash "$script_path"
fi

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

command -v bind >/dev/null 2>&1 || fail "bind no está disponible"

fhist() { :; }
fo() { :; }
cdf() { :; }
__atuin_history() { :; }

source "$repo_root/stow/bash/.bash_lib/keymap.sh" || fail "keymap no pudo cargarse"

key_bindings() {
  bind -X | grep -E '^"(\\C-r|\\C-t|\\e\\C-c)"'
}

snapshot_a="$(key_bindings)"
printf '%s\n' "$snapshot_a" | grep -Fq '"\C-r" "__atuin_history"' || fail "Ctrl-r no pertenece a Atuin"
printf '%s\n' "$snapshot_a" | grep -Fq '"\C-t" "_bash_keymap_files"' || fail "Ctrl-t no pertenece al selector de archivos"
printf '%s\n' "$snapshot_a" | grep -Fq '"\e\C-c" "_bash_keymap_dirs"' || fail "Alt-c no pertenece al selector de directorios"
if printf '%s\n' "$snapshot_a" | grep -Fq '"\C-s"'; then
  fail "el keymap Bash se apropió de Ctrl-s"
fi
pass "Readline tiene owners únicos y Ctrl-s sigue libre"

completion_a="$(bind -q menu-complete; bind -q menu-complete-backward 2>/dev/null || true)"
printf '%s\n' "$completion_a" | grep -Fq 'menu-complete' || fail "Tab perdió menu-complete"
printf '%s\n' "$completion_a" | grep -Fq 'menu-complete-backward' || fail "Shift-Tab perdió menu-complete-backward"
pass "completion de Tab estable"

. "$repo_root/stow/bash/.bash_lib/keymap.sh"
snapshot_b="$(key_bindings)"
completion_b="$(bind -q menu-complete; bind -q menu-complete-backward 2>/dev/null || true)"
[ "$snapshot_a" = "$snapshot_b" ] || fail "recargar keymap cambia bindings"
[ "$completion_a" = "$completion_b" ] || fail "recargar keymap cambia completion"
pass "reload de keymap idempotente"

unset -f fhist fo cdf __atuin_history
_bash_keymap_history >/dev/null 2>"/tmp/bash-keymap-missing.err" && fail "fallback de history no detectó owner ausente"
_bash_keymap_files >/dev/null 2>"/tmp/bash-keymap-missing.err" && fail "selector de archivos no detectó owner ausente"
_bash_keymap_dirs >/dev/null 2>"/tmp/bash-keymap-missing.err" && fail "selector de directorios no detectó owner ausente"
rm -f /tmp/bash-keymap-missing.err
pass "owners ausentes fallan limpiamente"

bash -n "$repo_root/stow/bash/.bash_lib/keymap.sh" || fail "sintaxis keymap"
bash -n "$repo_root/stow/bash/.bashrc" || fail "sintaxis bashrc"
pass "sintaxis Bash válida"
