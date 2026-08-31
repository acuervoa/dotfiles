#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_home"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

mkdir -p "$tmp_home/.bash_lib" \
  "$tmp_home/.local/bin" "$tmp_home/bin" "$tmp_home/.bun/bin" \
  "$tmp_home/.opencode/bin" "$tmp_home/.local/share/composer/vendor/bin"
cp "$repo_root/stow/bash/.profile" "$tmp_home/.profile"
cp "$repo_root/stow/bash/.bash_profile" "$tmp_home/.bash_profile"
cp "$repo_root/stow/bash/.bashrc" "$tmp_home/.bashrc"
cp "$repo_root/stow/bash/.bash_aliases" "$tmp_home/.bash_aliases"
cp "$repo_root/stow/bash/.bash_functions" "$tmp_home/.bash_functions"
cp "$repo_root/stow/bash/.bash_lib/"*.sh "$tmp_home/.bash_lib/"
printf 'export PATH="$HOME/bin:$PATH"\n' >"$tmp_home/.bashrc_local"

base_path="$tmp_home/.local/bin:$tmp_home/bin:$tmp_home/.bun/bin:$tmp_home/.opencode/bin:$tmp_home/.local/share/composer/vendor/bin:$tmp_home/.local/bin:$tmp_home/bin:/usr/bin:/bin"

run_path() {
  local login_flag="$1"
  if [ "$login_flag" = login ]; then
    env -i HOME="$tmp_home" PATH="$base_path" TERM=xterm-256color \
      bash --login -ic 'printf "%s\n" "$PATH"' 2>/dev/null
  else
    env -i HOME="$tmp_home" PATH="$base_path" TERM=xterm-256color \
      bash --noprofile --norc -ic '. "$HOME/.profile"; . "$HOME/.bashrc"; printf "%s\n" "$PATH"' 2>/dev/null
  fi
}

assert_unique_and_ordered() {
  local path_value="$1"
  local duplicate_count
  duplicate_count="$(tr ':' '\n' <<<"$path_value" | sort | uniq -d | wc -l)"
  [ "$duplicate_count" -eq 0 ] || fail "PATH contiene $duplicate_count rutas duplicadas: $(tr ':' '\n' <<<"$path_value" | sort | uniq -d | tr '\n' ' ')"

  local expected index=0 previous=-1
  for expected in \
    "$tmp_home/.local/bin" "$tmp_home/bin" "$tmp_home/.bun/bin" \
    "$tmp_home/.opencode/bin" "$tmp_home/.local/share/composer/vendor/bin"; do
    index=$((index + 1))
    local current
    current="$(tr ':' '\n' <<<"$path_value" | nl -ba | awk -v p="$expected" '$2 == p {print $1; exit}')"
    [ -n "$current" ] || fail "falta ruta estática: $expected"
    [ "$current" -gt "$previous" ] || fail "orden estático incorrecto: $expected"
    previous="$current"
  done
}

login_path="$(run_path login)"
non_login_path="$(run_path non-login)"
assert_unique_and_ordered "$login_path"
assert_unique_and_ordered "$non_login_path"
pass "login y no-login sin duplicados y con precedencia estable"

reload_paths="$({
  env -i HOME="$tmp_home" PATH="$base_path" TERM=xterm-256color bash --noprofile --norc -ic '
    export PS1=\$\n
    . "$HOME/.profile"
    . "$HOME/.bashrc"
    first="$PATH"
    . "$HOME/.bashrc"
    printf "%s\n%s\n" "$first" "$PATH"
  '
} 2>/dev/null)"
first_path="${reload_paths%%$'\n'*}"
second_path="${reload_paths#*$'\n'}"
[ "$first_path" = "$second_path" ] || fail "reload cambia PATH"
assert_unique_and_ordered "$second_path"
pass "reload idempotente"
