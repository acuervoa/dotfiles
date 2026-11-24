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

# 11. `daily` solo es subcomando con forma de comando (F3): sin args, con fecha suelta o con --flags.
#     Una frase que empiece por `daily` sigue siendo una entrada. Los inválidos no escriben nada.
vault="$tmp_dir/vault11"
mkdir -p "$vault/DAILY"
printf '# daily\n' >"$vault/DAILY/$today.md"
printf '# daily\n' >"$vault/DAILY/2026-10-19.md"
tree_state() { # estado (rutas, hashes) de un directorio; vacío si no existe
  [ -e "$1" ] && find "$1" -type f -exec sha256sum {} + | sort -k2
  stat -c '%n %Y.%y' "$1"/DAILY/* 2>/dev/null
  return 0
}
wl_before="$(tree_state "$WORKLOG_DIR")"
vault_before="$(tree_state "$vault")"

# daily_invalid ETIQUETA ARGS...: rc=1, stderr `wl:`, sin mensaje de éxito, nada escrito.
daily_invalid() {
  local label="$1"; shift
  local out rc
  out="$(wl "$@" 2>"$tmp_dir/err11")"; rc=$?
  [ "$rc" -eq 1 ] || fail "$label: rc esperado 1, obtenido $rc"
  grep -q '^wl: ' "$tmp_dir/err11" || fail "$label: stderr sin prefijo 'wl:'"
  [ -z "$out" ] || fail "$label: stdout no vacío ($out)"
  printf '%s\n' "$out" | grep -Eq 'entradas|sin entradas|sin cambios|registrado|✅' && fail "$label: mensaje de éxito"
  [ "$(tree_state "$WORKLOG_DIR")" = "$wl_before" ] || fail "$label: modificó el worklog"
  [ "$(tree_state "$vault")" = "$vault_before" ] || fail "$label: modificó el vault"
  # WORKLOG_DIR inexistente: no se crea
  rm -rf -- "$tmp_dir/wl_absent"
  WORKLOG_DIR="$tmp_dir/wl_absent" wl "$@" >/dev/null 2>&1
  [ ! -e "$tmp_dir/wl_absent" ] || fail "$label: creó un WORKLOG_DIR inexistente"
}
daily_invalid "daily sin args" daily
daily_invalid "daily con fecha" daily 2026-10-19
daily_invalid "daily con fecha y --vault" daily 2026-10-19 --vault "$vault"
daily_invalid "--vault sin valor" daily --vault
daily_invalid "--date sin --vault" daily --date 2026-10-19
daily_invalid "fecha inválida" daily --vault "$vault" --date 2026-13-45
daily_invalid "nota inexistente" daily --vault "$vault" --date 2020-01-01
pass "daily inválido: rc=1, wl:, sin escritura ni mensaje de éxito"

# Válido con --vault: vuelca las entradas de hoy en la nota temporal.
out="$(wl daily --vault "$vault")" || fail "daily --vault falló"
printf '%s\n' "$out" | grep -q "$today.md: [0-9]* entradas" || fail "daily --vault sin resumen (obtenido: $out)"
grep -q 'sin agente' "$vault/DAILY/$today.md" || fail "daily --vault no volcó las entradas"
# Válido con --vault y --date (sin entradas ese día: no se toca la nota)
before="$(sha256sum "$vault/DAILY/2026-10-19.md")"
out="$(wl daily --vault "$vault" --date 2026-10-19)" || fail "daily --vault --date falló"
[ "$out" = "sin entradas; no se toca la daily" ] || fail "daily --date sin entradas: salida inesperada ($out)"
[ "$(sha256sum "$vault/DAILY/2026-10-19.md")" = "$before" ] || fail "daily --date sin entradas tocó la nota"
pass "daily --vault y daily --vault --date siguen siendo comando"

# Texto libre: se registra como entrada.
n0="$(line_count)"
wl daily me cansé >/dev/null || fail "daily me cansé falló"
[ "$(line_count)" -eq $((n0 + 1)) ] || fail "daily me cansé no añadió una entrada"
[ "$(jget texto)" = "daily me cansé" ] || fail "daily me cansé: texto alterado ($(jget texto))"
wl daily 20261019 >/dev/null || fail "daily 20261019 falló"
[ "$(line_count)" -eq $((n0 + 2)) ] || fail "daily 20261019 no añadió una entrada"
[ "$(jget texto)" = "daily 20261019" ] || fail "daily 20261019: texto alterado ($(jget texto))"
pass "frases que empiezan por daily se registran como entrada"

# `daily -x` (fuera de alcance F3): se conserva el comportamiento previo, sea el que sea.
# Previo: -x no empieza por `--`, así que se trata como entrada de texto.
n1="$(line_count)"
wl daily -x >/dev/null || fail "daily -x cambió de comportamiento (rc)"
[ "$(line_count)" -eq $((n1 + 1)) ] || fail "daily -x cambió de comportamiento (ya no se registra)"
[ "$(jget texto)" = "daily -x" ] || fail "daily -x cambió de comportamiento (texto)"
pass "daily -x conserva su comportamiento previo"

# 12. wl sync sobre un repositorio sin commits (H2): no debe intentar `git push -u origin HEAD`.
# Remoto: bare local por file://, sin red. Un wrapper de git registra las invocaciones de `wl sync`.
export GIT_AUTHOR_NAME="wl test" GIT_AUTHOR_EMAIL="wl-test@example.invalid"
export GIT_COMMITTER_NAME="wl test" GIT_COMMITTER_EMAIL="wl-test@example.invalid"
real_git="$(command -v git)"
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/git" <<WRAP
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"\$GITCALLS12"
exec "$real_git" "\$@"
WRAP
chmod +x "$tmp_dir/bin/git"

# sync12 NOMBRE: wl sync con el wrapper (solo aquí) y log propio; deja rc/err/calls en variables.
sync12() {
  GITCALLS12="$tmp_dir/gitcalls12$1"
  : >"$GITCALLS12"
  sync12_out="$(GITCALLS12="$GITCALLS12" PATH="$tmp_dir/bin:$PATH" WORKLOG_DIR="$tmp_dir/wl12$1" WORKLOG_HOST="h12$1" wl sync 2>"$tmp_dir/err12$1")"
  sync12_rc=$?
  sync12_err="$(cat "$tmp_dir/err12$1")"
}
# init12 NOMBRE REMOTO: wl init con WORKLOG_DIR propio.
init12() {
  WORKLOG_DIR="$tmp_dir/wl12$1" wl init "file://$tmp_dir/$2.git" --host "h12$1" >/dev/null 2>&1 || fail "12$1: wl init falló"
}
has_push12() { grep -Eq '(^| )push( |$)' "$tmp_dir/gitcalls12$1"; }
has_pull12() { grep -Eq '(^| )pull( |$)' "$tmp_dir/gitcalls12$1"; }
# seed12 REMOTO RAMA: un tercero publica un commit en RAMA del remoto.
seed12() {
  "$real_git" clone -q "file://$tmp_dir/$1.git" "$tmp_dir/seed12$1" 2>/dev/null || fail "12: clone de siembra falló"
  "$real_git" -C "$tmp_dir/seed12$1" checkout -q -b "$2"
  printf 'x\n' >"$tmp_dir/seed12$1/seed"
  "$real_git" -C "$tmp_dir/seed12$1" add seed
  "$real_git" -C "$tmp_dir/seed12$1" commit -q -m seed
  "$real_git" -C "$tmp_dir/seed12$1" push -q origin "$2" 2>/dev/null || fail "12: push de siembra falló"
}

# 12a: remoto vacío, sin entradas -> error claro, rc=2, sin push y sin refs en el remoto.
"$real_git" init -q --bare -b main "$tmp_dir/r12a.git"
init12 a r12a
sync12 a
[ "$sync12_rc" -eq 2 ] || fail "12a: rc esperado 2, obtenido $sync12_rc"
printf '%s\n' "$sync12_err" | grep -q '^wl:' || fail "12a: stderr sin prefijo wl: ($sync12_err)"
printf '%s\n' "$sync12_err" | grep -q 'no hay entradas que sincronizar' || fail "12a: mensaje inesperado ($sync12_err)"
[ -z "$sync12_out" ] || fail "12a: salida inesperada en stdout ($sync12_out)"
! has_push12 a || fail "12a: se intentó git push"
[ -z "$("$real_git" -C "$tmp_dir/r12a.git" for-each-ref)" ] || fail "12a: el remoto no debía tener refs"
pass "sync sin commits: rc=2, 'no hay entradas que sincronizar', sin push"

# 12b: remoto vacío, con una entrada -> sincroniza y publica un commit (control positivo del wrapper).
"$real_git" init -q --bare -b main "$tmp_dir/r12b.git"
init12 b r12b
WORKLOG_DIR="$tmp_dir/wl12b" WORKLOG_HOST="h12b" wl "entrada 12b" >/dev/null || fail "12b: no se pudo registrar la entrada"
sync12 b
[ "$sync12_rc" -eq 0 ] || fail "12b: rc esperado 0, obtenido $sync12_rc ($sync12_err)"
[ "$sync12_out" = "sincronizado" ] || fail "12b: salida inesperada ($sync12_out)"
has_push12 b || fail "12b: no se registró git push (wrapper sin efecto)"
[ "$("$real_git" -C "$tmp_dir/r12b.git" rev-list --count main)" -eq 1 ] || fail "12b: main del remoto no tiene 1 commit"
pass "sync con una entrada sobre remoto vacío: sincroniza y publica main"

# 12c: remoto con rama main sembrada por un tercero, sin entradas propias -> pull + push, rc=0.
"$real_git" init -q --bare -b main "$tmp_dir/r12c.git"
seed12 r12c main
init12 c r12c
sync12 c
[ "$sync12_rc" -eq 0 ] || fail "12c: rc esperado 0, obtenido $sync12_rc ($sync12_err)"
[ "$sync12_out" = "sincronizado" ] || fail "12c: salida inesperada ($sync12_out)"
has_pull12 c || fail "12c: no hubo git pull"
has_push12 c || fail "12c: no hubo git push"
pass "sync sin entradas propias sobre remoto con main: pull + push, rc=0"

# 12d (caracterización): init sobre remoto vacío, un tercero publica otra rama y el local sigue sin commits.
# Hoy falla en el pull (main no existe en el remoto): rc=2 con el mensaje de pull y sin push.
"$real_git" init -q --bare -b main "$tmp_dir/r12d.git"
init12 d r12d
seed12 r12d otra
sync12 d
[ "$sync12_rc" -eq 2 ] || fail "12d: rc esperado 2, obtenido $sync12_rc ($sync12_err)"
printf '%s\n' "$sync12_err" | grep -q '^wl: sin red o conflicto al hacer pull' || fail "12d: mensaje inesperado ($sync12_err)"
has_pull12 d || fail "12d: no hubo git pull"
! has_push12 d || fail "12d: se intentó git push"
pass "sync sin commits con otra rama en el remoto: falla en pull (rc=2), sin push"

printf 'OK\n'
