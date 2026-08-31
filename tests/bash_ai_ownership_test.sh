#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ai_file="$repo_root/stow/bash/.bash_lib/ai.sh"
bashrc="$repo_root/stow/bash/.bashrc"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

[ -f "$ai_file" ] || fail "no existe $ai_file"
[ -f "$bashrc" ] || fail "no existe $bashrc"

expected=(afs afc afd afa af afl afx aflastdraft afapplylast afdp afdb sbclose ai)

for name in "${expected[@]}"; do
  count="$(rg -c "^${name}[[:space:]]*\\(\\)|^alias[[:space:]]+${name}=" "$ai_file" || true)"
  [ "$count" -eq 1 ] || fail "$name debe tener exactamente un owner en ai.sh; count=$count"

  if rg -q "^${name}[[:space:]]*\\(\\)|^alias[[:space:]]+${name}=" "$bashrc"; then
    fail "$name sigue duplicado en .bashrc"
  fi
done
pass "cada orden AI tiene un único owner versionado en ai.sh"

if rg -n '127\\.0\\.0\\.1:3111|AGENTMEMORY_SECRET|API_KEY|TOKEN|sk-[A-Za-z0-9]' "$bashrc"; then
  fail ".bashrc contiene configuración potencialmente sensible o autostart externo"
fi
pass ".bashrc no contiene secretos ni autostart de AgentMemory"

tmp_home="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_home"' EXIT

mkdir -p "$tmp_home/.bash_lib"
cp "$bashrc" "$tmp_home/.bashrc"
cp "$repo_root/stow/bash/.bash_aliases" "$tmp_home/.bash_aliases"
cp "$repo_root/stow/bash/.bash_functions" "$tmp_home/.bash_functions"
cp "$repo_root/stow/bash/.profile" "$tmp_home/.profile"
cp "$repo_root/stow/bash/.bash_lib/"*.sh "$tmp_home/.bash_lib/"

cat >"$tmp_home/.bashrc_local" <<'EOF'
# Override local sintético sin secretos ni definiciones AI.
EOF

snapshot() {
  local name
  for name in "${expected[@]}"; do
    printf '%s=%s\n' "$name" "$(type -t "$name" 2>/dev/null || printf missing)"
  done
}

state="$(env -i HOME="$tmp_home" PATH="$tmp_home/.local/bin:$tmp_home/bin:/usr/bin:/bin" TERM=xterm-256color \
  bash --noprofile --norc -ic '. "$HOME/.profile"; . "$HOME/.bashrc"; snapshot() { for name in afs afc afd afa af afl afx aflastdraft afapplylast afdp afdb sbclose ai; do printf "%s=%s\\n" "$name" "$(type -t "$name" 2>/dev/null || printf missing)"; done; }; first="$(snapshot)"; . "$HOME/.bashrc"; . "$HOME/.bashrc"; second="$(snapshot)"; [ "$first" = "$second" ] || { printf "%s\\n%s\\n" "$first" "$second" >&2; exit 1; }; printf "%s\\n" "$second"' 2>/dev/null)" || fail "la shell sintética no pudo completar dos recargas"

expected_types=$'afs=alias\nafc=alias\nafd=alias\nafa=alias\naf=function\nafl=function\nafx=function\naflastdraft=function\nafapplylast=function\nafdp=function\nafdb=function\nsbclose=function\nai=function'

[ "$state" = "$expected_types" ] || {
  printf '%s\n' "$state" >&2
  fail "los tipos AI no son estables tras dos recargas"
}
pass "los tipos AI permanecen estables tras dos recargas"
