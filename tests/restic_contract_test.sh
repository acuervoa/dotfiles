#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timer="$repo_root/stow/systemd/.config/systemd/user/restic-backup.timer"
script="$repo_root/stow/bin/.local/bin/restic-backup.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

grep -q '^OnCalendar=Sat \*-\*-\* 02:00:00$' "$timer" || fail "timer Restic no es semanal en sábado"
grep -q '^Persistent=true$' "$timer" || fail "timer Restic no es persistente"
grep -q '^RandomizedDelaySec=15min$' "$timer" || fail "timer Restic no tiene delay aleatorio"
grep -q -- '--keep-weekly 8' "$script" || fail "falta retención semanal"
grep -q -- '--keep-monthly 12' "$script" || fail "falta retención mensual"
grep -q -- '--keep-yearly 2' "$script" || fail "falta retención anual"
if grep -qi 'diario' "$timer"; then
  fail "timer Restic todavía se describe como diario"
fi

printf '%s\n' 'PASS: contrato operativo de Restic'
