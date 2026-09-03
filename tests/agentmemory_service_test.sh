#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
unit="$repo_root/stow/systemd/.config/systemd/user/agentmemory.service"
bashrc="$repo_root/stow/bash/.bashrc"
entrypoint="$repo_root/stow/bin/.local/bin/agentmemory"
fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

[ -f "$unit" ] || fail "no existe la unidad: $unit"
[ -x "$entrypoint" ] || fail "no existe entrypoint versionado: $entrypoint"

grep -q '^ExecStart=%h/.local/bin/agentmemory$' "$unit" || fail "AgentMemory no usa el entrypoint estable del usuario"
if grep -q 'fnm' "$unit"; then
  fail "AgentMemory todavía depende de fnm"
fi

grep -q '^Restart=on-failure$' "$unit" || fail "falta Restart=on-failure"
grep -q '^RestartSec=5$' "$unit" || fail "falta RestartSec=5"
grep -q '^WantedBy=default.target$' "$unit" || fail "falta WantedBy=default.target"

if grep -Eq 'EnvironmentFile|AGENTMEMORY_SECRET|API_KEY|TOKEN|sk-[A-Za-z0-9]' "$unit"; then
  fail "la unidad contiene configuración sensible o EnvironmentFile"
fi
pass "unidad sin secretos y con lifecycle esperado"

if grep -q '127\.0\.0\.1:3111/agentmemory/health' "$bashrc" ||
  grep -q 'nohup agentmemory' "$bashrc"; then
  fail "Bash todavía posee el autostart de AgentMemory"
fi
pass "Bash no posee el autostart de AgentMemory"
