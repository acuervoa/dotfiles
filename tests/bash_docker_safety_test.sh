#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

project="$tmp_dir/project"
bin_dir="$tmp_dir/bin"
log="$tmp_dir/docker.log"
mkdir -p "$project" "$bin_dir"
touch "$project/compose.yml" "$log"

cat >"$bin_dir/docker" <<'EOF'
#!/usr/bin/env bash
set -u
if [ "$(basename "$0")" = docker-compose ]; then
  set -- compose "$@"
fi
printf '%s ' "$@" >>"$DOCKER_TEST_LOG"
printf '\n' >>"$DOCKER_TEST_LOG"
if [ "$1" = compose ] && [ "$2" = version ]; then
  printf 'Docker Compose version v2-test\n'
elif [ "$1" = compose ] && [ "$2" = ps ]; then
  printf 'php\n'
fi
exit 0
EOF
chmod +x "$bin_dir/docker"
ln -s docker "$bin_dir/docker-compose"

export DOCKER_TEST_LOG="$log"
export PATH="$bin_dir:$PATH"

run_in_project() {
  local command="$1"
  shift
  (
    cd "$project" || exit 1
    bash --noprofile --norc -c '
      source "$1/stow/bash/.bash_lib/core.sh"
      source "$1/stow/bash/.bash_lib/docker.sh"
      source "$1/stow/bash/.bash_aliases"
      shopt -s expand_aliases
      shift
      '"$command"' "$@"
    ' bash "$repo_root" "$@"
  )
}

reset_log() {
  : >"$log"
}

for command in pmig pseed pclear dorebuild; do
  reset_log
  printf 'n\n' | run_in_project "$command" >/dev/null 2>&1 || true
  [ ! -s "$log" ] || fail "$command ejecutó Docker tras rechazar la confirmación"
  pass "$command no invoca Docker sin confirmación"
done

reset_log
printf 'y\n' | run_in_project pmig || fail "pmig confirmado falló"
grep -Fxq 'compose exec php php artisan migrate ' "$log" ||
  fail "pmig no conservó los argumentos esperados"
pass "pmig confirmado conserva la operación"

reset_log
printf 'y\n' | run_in_project pseed >/dev/null 2>&1 || fail "pseed confirmado falló"
grep -Fxq 'compose exec php php artisan db:seed ' "$log" ||
  fail "pseed no conservó los argumentos esperados"
pass "pseed confirmado conserva la operación"

reset_log
printf 'y\n' | run_in_project pclear >/dev/null 2>&1 || fail "pclear confirmado falló"
clear_calls="$(grep -c '^compose exec php php artisan .*:clear $' "$log")"
[ "$clear_calls" -eq 3 ] || fail "pclear no ejecutó sus tres limpiezas"
pass "pclear confirmado conserva sus tres limpiezas"

reset_log
printf 'y\n' | run_in_project dorebuild >/dev/null 2>&1 || fail "dorebuild confirmado falló"
grep -Fxq 'compose build --no-cache ' "$log" &&
  grep -Fxq 'compose up -d ' "$log" ||
  fail "dorebuild no conservó build --no-cache y up -d"
pass "dorebuild confirmado conserva el rebuild"

reset_log
printf 'y\n' | run_in_project dcrb >/dev/null 2>&1 || fail "dcrb confirmado falló"
grep -Fxq 'compose build --no-cache ' "$log" &&
  grep -Fxq 'compose up -d ' "$log" ||
  fail "dcrb no delegó en el rebuild protegido"
pass "dcrb delega en el rebuild protegido"

for command in 'p --version' 'part route:list' 'ptest' 'pstan' 'pint' 'proute'; do
  reset_log
  run_in_project "$command" >/dev/null 2>&1 || fail "$command falló"
  [ -s "$log" ] || fail "$command no delegó en Compose"
  pass "$command permanece instantáneo"
done
