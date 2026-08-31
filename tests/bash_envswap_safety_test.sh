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
mkdir -p "$project"
printf 'ACTIVE=local\n' >"$project/.env"
printf 'ACTIVE=staging\n' >"$project/.env.staging"
printf 'ACTIVE=production\n' >"$project/.env.production"
chmod 600 "$project/.env" "$project/.env.staging" "$project/.env.production"

run_envswap() {
  local input="$1"
  shift
  (
    cd "$project" || exit 1
    source "$repo_root/stow/bash/.bash_lib/core.sh"
    source "$repo_root/stow/bash/.bash_lib/misc.sh"
    printf '%s\n' "$input" | envswap "$@"
  )
}

cp "$project/.env" "$tmp_dir/active-before-reject"
run_envswap n use staging >/dev/null 2>"$tmp_dir/reject.err" || true
cmp -s "$project/.env" "$tmp_dir/active-before-reject" ||
  fail "envswap modificó .env tras rechazar"
if find "$project" -maxdepth 1 -name '.env.bak.*' -print -quit | grep -q .; then
  fail "envswap creó backup tras rechazar"
fi
pass "envswap rechaza sin modificar"

run_envswap y use staging >/dev/null 2>"$tmp_dir/activate.err" || fail "activación staging falló"
cmp -s "$project/.env" "$project/.env.staging" || fail ".env no coincide con staging"
backups=("$project"/.env.bak.*)
[ "${#backups[@]}" -eq 1 ] || fail "se esperaba un backup tras la primera activación"
cmp -s "${backups[0]}" "$tmp_dir/active-before-reject" || fail "backup no conserva el .env anterior"
[ "$(stat -c '%a' "$project/.env")" = 600 ] || fail ".env no tiene permisos 600"
[ "$(stat -c '%a' "${backups[0]}")" = 600 ] || fail "backup no tiene permisos 600"
pass "envswap activa y crea backup privado"

cp "$project/.env" "$tmp_dir/active-before-second"
run_envswap y use production >/dev/null 2>"$tmp_dir/second.err" || fail "segunda activación falló"
backups=("$project"/.env.bak.*)
[ "${#backups[@]}" -eq 2 ] || fail "los backups colisionaron o faltan"
cmp -s "$project/.env" "$project/.env.production" || fail ".env no coincide con production"
newest="$(find "$project" -maxdepth 1 -name '.env.bak.*' -printf '%T@ %p\n' | sort -n | tail -n 1 | cut -d' ' -f2- )"
[ -n "$newest" ] || fail "no se encontró el backup más reciente"
cmp -s "$newest" "$tmp_dir/active-before-second" || fail "segundo backup no conserva el estado anterior"
pass "envswap evita colisiones de backup"

before_list="$(cmp -s "$project/.env" "$project/.env.production"; printf '%s' "$?")"
list_output="$(cd "$project" && source "$repo_root/stow/bash/.bash_lib/core.sh" && source "$repo_root/stow/bash/.bash_lib/misc.sh" && envswap list)"
printf '%s\n' "$list_output" | grep -Fxq staging || fail "envswap list no muestra staging"
printf '%s\n' "$list_output" | grep -Fxq production || fail "envswap list no muestra production"
after_list="$(cmp -s "$project/.env" "$project/.env.production"; printf '%s' "$?")"
[ "$before_list" = "$after_list" ] || fail "envswap list modificó .env"
pass "envswap list es no mutante"
