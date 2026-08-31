#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

tmp_dir="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_dir"' EXIT

real_git="$(command -v git)"
wrapper_dir="$tmp_dir/bin"
mkdir -p "$wrapper_dir"
cat >"$wrapper_dir/git" <<'EOF'
#!/usr/bin/env bash
set -u
if [ "${1:-}" = push ]; then
  printf '%s\n' "$*" >>"${GIT_TEST_LOG:?}"
  exit 0
fi
exec "${REAL_GIT:?}" "$@"
EOF
chmod +x "$wrapper_dir/git"

export REAL_GIT="$real_git"
export GIT_TEST_LOG="$tmp_dir/git.log"
touch "$GIT_TEST_LOG"

gpf_test_repo="$tmp_dir/gpf-repo"
mkdir -p "$gpf_test_repo"
git -C "$gpf_test_repo" init -q
git -C "$gpf_test_repo" config user.email test@example.invalid
git -C "$gpf_test_repo" config user.name test
printf 'base\n' >"$gpf_test_repo/README.md"
git -C "$gpf_test_repo" add README.md
git -C "$gpf_test_repo" commit -q -m initial

(
  cd "$gpf_test_repo" || exit 1
  PATH="$wrapper_dir:$PATH" bash --noprofile --norc -c '
    source "$1/stow/bash/.bash_lib/core.sh"
    source "$1/stow/bash/.bash_lib/git.sh"
    source "$1/stow/bash/.bash_aliases"
    shopt -s expand_aliases
    printf "n\n" | gpf
  ' bash "$repo_root"
) || fail "gpf rechazado devolvió error inesperado"

if grep -q '^push ' "$GIT_TEST_LOG"; then
  fail "gpf ejecutó push después de rechazar la confirmación"
fi
pass "gpf no ejecuta push sin confirmación"

(
  cd "$gpf_test_repo" || exit 1
  PATH="$wrapper_dir:$PATH" bash --noprofile --norc -c '
    source "$1/stow/bash/.bash_lib/core.sh"
    source "$1/stow/bash/.bash_lib/git.sh"
    source "$1/stow/bash/.bash_aliases"
    shopt -s expand_aliases
    printf "y\n" | gpf
  ' bash "$repo_root"
) || fail "gpf confirmado devolvió error inesperado"

[ "$(cat "$GIT_TEST_LOG")" = 'push --force-with-lease' ] ||
  fail "gpf no usó exactamente --force-with-lease"
pass "gpf confirmado usa force-with-lease"

new_repo() {
  local dir="$1"
  mkdir -p "$dir"
  mkdir -p "$dir/hooks"
  git -C "$dir" init -q
  git -C "$dir" config user.email test@example.invalid
  git -C "$dir" config user.name test
  git -C "$dir" config core.hooksPath "$dir/hooks"
  printf 'base\n' >"$dir/README.md"
  git -C "$dir" add README.md
  git -C "$dir" commit -q -m initial
}

sensitive_repo="$tmp_dir/sensitive-repo"
new_repo "$sensitive_repo"
printf 'do not commit\n' >"$sensitive_repo/.env"
git -C "$sensitive_repo" add .env

(
  cd "$sensitive_repo" || exit 1
  source "$repo_root/stow/bash/.bash_lib/core.sh"
  source "$repo_root/stow/bash/.bash_lib/git.sh"
  wip
) >/dev/null 2>"$tmp_dir/sensitive.err" && fail "wip permitió una ruta sensible"

[ "$(git -C "$sensitive_repo" rev-list --count HEAD)" -eq 1 ] ||
  fail "wip creó un commit con una ruta sensible"
pass "wip bloquea rutas sensibles staged"

normal_repo="$tmp_dir/normal-repo"
new_repo "$normal_repo"
printf 'change\n' >>"$normal_repo/README.md"
git -C "$normal_repo" add README.md

(
  cd "$normal_repo" || exit 1
  source "$repo_root/stow/bash/.bash_lib/core.sh"
  source "$repo_root/stow/bash/.bash_lib/git.sh"
  wip
) >/dev/null 2>"$tmp_dir/normal.err" || fail "wip rechazó una ruta normal"

[ "$(git -C "$normal_repo" rev-list --count HEAD)" -eq 2 ] ||
  fail "wip no creó el commit normal"
pass "wip permite rutas normales"
