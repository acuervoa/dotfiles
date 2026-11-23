#!/usr/bin/env bash
# Contrato de `wl`: identidad opcional de agente (campo `agente`) y compatibilidad JSONL.
# Todo ocurre en un sandbox temporal: nunca toca el worklog real ni la red.
set -u

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wl_src="$repo_root/stow/bin/.local/bin/wl"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$1"
}

tmp_dir="$(mktemp -d)"
trap '/usr/bin/rm -rf -- "$tmp_dir"' EXIT

export PYTHONDONTWRITEBYTECODE=1
export HOME="$tmp_dir/home"
export XDG_CONFIG_HOME="$tmp_dir/config"
export WORKLOG_DIR="$tmp_dir/worklog"
export WORKLOG_HOST="testhost"
unset WORKLOG_AGENT
mkdir -p "$HOME" "$XDG_CONFIG_HOME"

today="$(date +%F)"
log="$WORKLOG_DIR/testhost/$today.jsonl"

wl() { python3 "$wl_src" "$@"; }

# Última línea del log del equipo de pruebas, y número de líneas.
last_line() { tail -n 1 "$log"; }
line_count() { if [ -f "$log" ]; then wc -l <"$log" | tr -d ' '; else printf '0'; fi; }

# jget CAMPO: valor del campo en la última línea ("<ausente>" si no existe la clave).
jget() {
  last_line | python3 -c '
import json, sys
e = json.loads(sys.stdin.read())
v = e.get(sys.argv[1], "<ausente>")
print("<null>" if v is None else v)
' "$1"
}

# 1. Sin agente: la clave se omite, nunca null.
wl "sin agente" >/dev/null || fail "wl sin agente devolvió error"
[ "$(jget agente)" = "<ausente>" ] || fail "sin agente debe omitir la clave (obtenido: $(jget agente))"
[ "$(jget tipo)" = "hecho" ] || fail "tipo por defecto incorrecto"
pass "sin agente omite la clave"

# 2. Con -a.
wl -a planificador "con cli" >/dev/null || fail "wl -a devolvió error"
[ "$(jget agente)" = "planificador" ] || fail "-a no escribió el agente"
[ "$(jget texto)" = "con cli" ] || fail "-a alteró el texto"
pass "-a escribe agente"

# 3. -a combinado con -l/-d/-b en cualquier orden.
wl -a revisor -l "orden uno" >/dev/null || fail "-a -l devolvió error"
[ "$(jget agente)" = "revisor" ] && [ "$(jget tipo)" = "aprendizaje" ] || fail "-a -l incorrecto"
wl -d -a revisor "orden dos" >/dev/null || fail "-d -a devolvió error"
[ "$(jget agente)" = "revisor" ] && [ "$(jget tipo)" = "decision" ] || fail "-d -a incorrecto"
pass "-a se combina con -l/-d/-b en cualquier orden"

# 4. Un -a tras la primera palabra es texto literal.
wl hola -a x >/dev/null || fail "texto con -a final devolvió error"
[ "$(jget texto)" = "hola -a x" ] && [ "$(jget agente)" = "<ausente>" ] || fail "-a tras texto debe ser literal"
pass "-a solo es flag al inicio"

# 5. WORKLOG_AGENT como fallback; vacío = ausente.
WORKLOG_AGENT=implementador wl "con entorno" >/dev/null || fail "WORKLOG_AGENT devolvió error"
[ "$(jget agente)" = "implementador" ] || fail "WORKLOG_AGENT no se usó"
WORKLOG_AGENT="" wl "entorno vacío" >/dev/null || fail "WORKLOG_AGENT vacío devolvió error"
[ "$(jget agente)" = "<ausente>" ] || fail "WORKLOG_AGENT vacío debe omitir la clave"
pass "WORKLOG_AGENT como fallback"

# 6. Precedencia: -a gana al entorno.
WORKLOG_AGENT=implementador wl -a planificador "precedencia" >/dev/null || fail "precedencia devolvió error"
[ "$(jget agente)" = "planificador" ] || fail "-a debe prevalecer sobre WORKLOG_AGENT"
pass "-a prevalece sobre WORKLOG_AGENT"

# 7. Valores inválidos: rc=1 y sin persistencia.
before="$(line_count)"
for bad in "con espacio" "-x" ".punto" "a/b" 'a"b'; do
  wl -a "$bad" "texto" >/dev/null 2>&1
  rc=$?
  [ "$rc" -eq 1 ] || fail "-a '$bad' debe devolver 1 (obtenido: $rc)"
done
wl -a >/dev/null 2>&1; [ $? -eq 1 ] || fail "-a sin valor debe devolver 1"
wl -a "" "texto" >/dev/null 2>&1; [ $? -eq 1 ] || fail "-a vacío debe devolver 1"
WORKLOG_AGENT="malo nombre" wl "texto" >/dev/null 2>&1; [ $? -eq 1 ] || fail "WORKLOG_AGENT inválido debe devolver 1"
[ "$(line_count)" = "$before" ] || fail "un valor inválido persistió una entrada"
pass "valores inválidos rechazados sin persistencia"

# 8. today: identidad solo si existe.
out="$(wl today)"
printf '%s\n' "$out" | grep -F 'sin agente [testhost]' >/dev/null || fail "today debe mantener [host] sin agente"
printf '%s\n' "$out" | grep -F 'con cli [testhost/planificador]' >/dev/null || fail "today debe mostrar [host/agente]"
printf '%s\n' "$out" | grep -F 'null' >/dev/null && fail "today no debe mostrar null"
pass "today muestra identidad solo cuando existe"

# 9. Mezcla de registros y deduplicación por id entre equipos (línea con y sin agente).
mkdir -p "$WORKLOG_DIR/otro"
ts="$(date +%Y-%m-%dT%H:%M:%S%:z)"
printf '{"id":"dup000000001","ts":"%s","host":"otro","tipo":"hecho","texto":"duplicada"}\n' "$ts" >"$WORKLOG_DIR/otro/$today.jsonl"
printf '{"id":"dup000000001","ts":"%s","host":"otro","tipo":"hecho","texto":"duplicada","agente":"revisor"}\n' "$ts" >>"$WORKLOG_DIR/otro/$today.jsonl"
out="$(wl today 2>"$tmp_dir/err")"
[ "$(printf '%s\n' "$out" | grep -c 'duplicada')" -eq 1 ] || fail "la deduplicación por id debe dejar una sola entrada"
[ ! -s "$tmp_dir/err" ] || fail "wl today emitió avisos con registros mixtos"
pass "registros mixtos y deduplicación por id"

# 10. Lector anterior (versión original de wl, dfdd782) lee logs con `agente` sin perder entradas.
baseline_rev="dfdd7828bc36715fc40f41148bbae5cf1ef53cd2"
baseline_blob="02901f85d874e6bb518a882ef6a9dcf0c54d8deb" # wl original, anterior a `agente`
if [ "$(git -C "$repo_root" rev-parse "$baseline_rev:stow/bin/.local/bin/wl" 2>/dev/null)" = "$baseline_blob" ]; then
  git -C "$repo_root" show "$baseline_rev:stow/bin/.local/bin/wl" >"$tmp_dir/wl_old"
  new_out="$(wl today 2>/dev/null)"
  old_out="$(python3 "$tmp_dir/wl_old" today 2>"$tmp_dir/err_old")" \
    || fail "el lector anterior falló con campos nuevos"
  [ ! -s "$tmp_dir/err_old" ] || fail "el lector anterior emitió avisos con campos nuevos"
  [ "$(printf '%s\n' "$new_out" | wc -l)" -eq "$(printf '%s\n' "$old_out" | wc -l)" ] \
    || fail "el lector anterior perdió o añadió entradas"
  printf '%s\n' "$old_out" | grep -F 'con cli' >/dev/null || fail "el lector anterior no ve la entrada con agente"
  pass "el lector anterior (dfdd782) tolera el campo agente"
else
  fail "dfdd782 no contiene la versión original de wl (clon superficial o historia reescrita); no se puede comprobar el lector anterior"
fi

printf 'OK\n'
