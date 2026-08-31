#!/usr/bin/env bash
set -u

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
catalog="$repo_root/stow/bash/.bash_grammar"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

[ -f "$catalog" ] || fail "no existe el catálogo Bash"

catalog_names="$(awk -F '\t' 'NR > 1 && $1 !~ /^#/ {print $1}' "$catalog" | sort)"
[ -n "$catalog_names" ] || fail "el catálogo está vacío"

duplicate="$(awk -F '\t' 'NR > 1 && $1 !~ /^#/ {count[$1]++} END {for (n in count) if (count[n] > 1) print n}' "$catalog")"
[ -z "$duplicate" ] || fail "hay nombres duplicados en el catálogo: $duplicate"

awk -F '\t' 'NR == 1 {next} $1 !~ /^#/ {
  if (NF != 6) {printf "fila inválida en línea %d\n", NR; bad=1}
  if ($2 !~ /^(git|docker|php|runtime|ai|simplebrain|navigation|system|utility)$/) {printf "grupo inválido: %s\n", $2; bad=1}
  if ($3 !~ /^(safe|confirm|mutating)$/) {printf "riesgo inválido: %s\n", $3; bad=1}
  if ($4 !~ /^(yes|no)$/) {printf "micro inválido: %s\n", $4; bad=1}
} END {exit bad}' "$catalog" || fail "metadatos inválidos en el catálogo"
pass "metadatos del catálogo válidos"

defined="$(
  sed -nE 's/^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_.-]+)=.*/\1/p' \
    "$repo_root/stow/bash/.bash_aliases" "$repo_root/stow/bash/.bash_lib/"*.sh
  sed -nE 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z][a-zA-Z0-9_-]*)[[:space:]]*(\(\))?[[:space:]]*\{.*/\2/p' \
    "$repo_root/stow/bash/.bash_lib/"*.sh "$repo_root/stow/bash/.bashrc" |
    awk '!/^_/ && !/^(move_to_front|move_to_end)$/ {print}'
  printf '%s\n' n z
)"
missing="$(comm -23 <(printf '%s\n' "$defined" | sort -u) <(printf '%s\n' "$catalog_names"))"
[ -z "$missing" ] || fail "comandos sin catálogo: $missing"

unknown="$(comm -13 <(printf '%s\n' "$defined" | sort -u) <(printf '%s\n' "$catalog_names"))"
[ -z "$unknown" ] || fail "entradas del catálogo sin comando: $unknown"
pass "catálogo sincronizado con comandos públicos"

micro="$(awk -F '\t' 'NR > 1 && $4 == "yes" {print $1}' "$catalog" | sort | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
[ "$micro" = 'l n p r y z' ] || fail "micro-atajos inesperados: $micro"
pass "micro-atajos estables: $micro"

if rg -n 'sk-[A-Za-z0-9]|GMAIL_APP_PASS|ANTHROPIC_API_KEY|\.bashrc_local' "$catalog"; then
  fail "el catálogo contiene patrones sensibles o referencia al override local"
fi
pass "catálogo sin secretos ni overrides locales"

generator="$repo_root/scripts/generate_bash_shortcuts.sh"
[ -x "$generator" ] || fail "generador no ejecutable"
bash "$generator" >/dev/null 2>&1 || fail "el generador no pudo ejecutarse"
generated_before="$(mktemp)"
trap '/usr/bin/rm -f -- "$generated_before"' EXIT
cp "$repo_root/BASH_SHORTCUTS.md" "$generated_before"
bash "$generator" >/dev/null 2>&1 || fail "segunda generación falló"
cmp -s "$generated_before" "$repo_root/BASH_SHORTCUTS.md" || fail "generación no idempotente"
if rg -n 'sk-[A-Za-z0-9]|GMAIL_APP_PASS|ANTHROPIC_API_KEY|\.bashrc_local|/home/[a-zA-Z0-9_.-]+/' "$repo_root/BASH_SHORTCUTS.md"; then
  fail "el cheatsheet contiene datos sensibles o rutas privadas"
fi
pass "cheatsheet reproducible y sin datos privados"

dothelp_a="$(BASH_GRAMMAR_FILE="$catalog" bash --noprofile --norc -ic '. "$1/stow/bash/.bash_lib/core.sh"; dothelp' bash "$repo_root" 2>/dev/null)"
dothelp_b="$(BASH_GRAMMAR_FILE="$catalog" bash --noprofile --norc -ic '. "$1/stow/bash/.bash_lib/core.sh"; dothelp' bash "$repo_root" 2>/dev/null)"
[ "$dothelp_a" = "$dothelp_b" ] || fail "dothelp no es idempotente"
printf '%s\n' "$dothelp_a" | grep -Fq 'gpf' || fail "dothelp no muestra gpf"
printf '%s\n' "$dothelp_a" | grep -Fq 'af' || fail "dothelp no muestra AI Flow"
pass "dothelp agrupado e idempotente"
