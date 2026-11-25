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

# ---------------------------------------------------------------------------
# Helpers comunes de las secciones 13 en adelante.
# tree_hash DIR: hash del árbol incluyendo tipos, destinos de enlace y contenido de ficheros.
tree_hash() {
  if [ ! -e "$1" ] && [ ! -L "$1" ]; then printf 'ABSENT\n'; return 0; fi
  {
    if [ -L "$1" ]; then printf 'link %s\n' "$(readlink "$1")"; fi
    (cd "$1" && find . -printf '%y %p %l\n' | LC_ALL=C sort && find . -type f -exec sha256sum {} + | LC_ALL=C sort -k2)
  } | sha256sum | cut -d' ' -f1
}
# mk13 NOMBRE: crea $base (global) con un remoto bare vacío en $base/r.git. Datos locales: $base/wl.
mk13() {
  base="$tmp_dir/c13$1"
  mkdir -p "$base"
  "$real_git" init -q --bare -b main "$base/r.git"
}
# seed13 RAMA RUTA CONTENIDO: un tercero publica un fichero en RAMA del remoto de $base.
seed13() {
  local w
  w="$tmp_dir/seed13_$(basename "$base")"
  "$real_git" clone -q "file://$base/r.git" "$w" 2>/dev/null || fail "13: clone de siembra falló"
  "$real_git" -C "$w" checkout -q -b "$1"
  mkdir -p "$w/$(dirname "$2")"
  printf '%s\n' "$3" >"$w/$2"
  "$real_git" -C "$w" add -A
  "$real_git" -C "$w" commit -q -m seed
  "$real_git" -C "$w" push -q origin "$1" 2>/dev/null || fail "13: push de siembra falló"
}
# add13 HOST TEXTO...: wl "texto" en $base/wl como HOST (antes de wl init).
add13() { WORKLOG_DIR="$base/wl" WORKLOG_HOST="$1" wl "${@:2}" >/dev/null 2>&1 || fail "13: wl add falló"; }
# i13 HOST ARGS...: wl init con $base/wl y $base/cfg propios; deja i13_rc/i13_out/i13_err.
i13() {
  local h="$1"; shift
  i13_out="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST="$h" wl init "$@" 2>"$tmp_dir/err13")"
  i13_rc=$?
  i13_err="$(cat "$tmp_dir/err13")"
}
no_cfg13() { [ -z "$(find "$base/cfg" -type f 2>/dev/null)" ]; }
no_tmp13() { [ -z "$(find "$base" -maxdepth 1 -name '.wl.init-*')" ]; }

# 13. wl init adopta un directorio que solo contiene <equipo>/ (F1-B, añadir antes de init).
# 13.1 flujo real add -> init -> status -> today -> sync.
mk13 a
seed13 main seed.txt s
add13 h13 "e1"
f13="$base/wl/h13/$today.jsonl"
[ -f "$f13" ] || fail "13.1: wl no creó el fichero del día antes de init"
h_before="$(sha256sum <"$f13")"
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 0 ] || fail "13.1: init rc esperado 0, obtenido $i13_rc ($i13_err)"
case "$i13_out" in listo:*) ;; *) fail "13.1: stdout sin 'listo:' ($i13_out)" ;; esac
[ "$(cat "$base/cfg/worklog/host")" = "h13" ] || fail "13.1: la config no contiene h13"
[ -d "$base/wl/.git" ] || fail "13.1: no hay .git tras init"
[ "$(sha256sum <"$f13")" = "$h_before" ] || fail "13.1: el .jsonl cambió durante la adopción"
[ "$("$real_git" -C "$base/wl" status --porcelain)" = "?? h13/" ] || fail "13.1: status inesperado"
[ "$(printf '%s\n' "$i13_err" | grep -c 'adoptadas entradas locales')" -eq 1 ] || fail "13.1: debe haber UNA nota de adopción ($i13_err)"
printf '%s\n' "$i13_err" | grep -qF 'wl: adoptadas entradas locales de h13/ (sin confirmar; wl sync las publica)' || fail "13.1: texto de la nota ($i13_err)"
WORKLOG_DIR="$base/wl" WORKLOG_HOST=h13 wl today | grep -qF 'e1 [h13]' || fail "13.1: today no muestra e1"
sync13_out="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h13 wl sync 2>&1)" || fail "13.1: sync falló ($sync13_out)"
[ "$("$real_git" -C "$base/r.git" ls-tree -r --name-only main | grep -c "^h13/$today.jsonl$")" -eq 1 ] || fail "13.1: el commit no llegó al bare"
[ "$("$real_git" -C "$base/r.git" rev-list --count main)" -eq 2 ] || fail "13.1: main del bare debe tener seed + 1 commit"
pass "13.1 add->init adopta, status '?? h13/', today y sync publican; .jsonl idéntico"

# 13.2 remoto vacío (sin refs): adopta y sync publica main con 1 commit.
mk13 b
add13 h13 "e2"
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 0 ] || fail "13.2: init rc $i13_rc ($i13_err)"
WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h13 wl sync >/dev/null 2>&1 || fail "13.2: sync falló"
[ "$("$real_git" -C "$base/r.git" rev-list --count main)" -eq 1 ] || fail "13.2: main no tiene 1 commit"
pass "13.2 remoto vacío: adopta y sync publica 1 commit en main"

# 13.3 ruta convencional: root inexistente y root vacío, sin nota de adopción.
mk13 c1
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 0 ] || fail "13.3a: rc $i13_rc ($i13_err)"
[ "$(cat "$base/cfg/worklog/host")" = "h13" ] || fail "13.3a: config no escrita"
printf '%s\n' "$i13_err" | grep -q 'adoptadas' && fail "13.3a: nota de adopción en ruta convencional"
mk13 c2
mkdir "$base/wl"
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 0 ] || fail "13.3b: rc $i13_rc ($i13_err)"
[ "$(cat "$base/cfg/worklog/host")" = "h13" ] || fail "13.3b: config no escrita"
printf '%s\n' "$i13_err" | grep -q 'adoptadas' && fail "13.3b: nota de adopción en ruta convencional"
case "$i13_out" in listo:*) ;; *) fail "13.3: stdout sin listo" ;; esac
pass "13.3 root inexistente o vacío: clone directo, config escrita, sin nota"

# 13.4 NO adoptable: rc=1, «ya existe y no está vacío», stdout vacío, sin config ni temporales, árbol intacto.
for sub in suelto git_vacio otro_dir symlink_en_eff subdir_en_eff fichero_en_eff root_symlink; do
  mk13 "d_$sub"
  seed13 main seed.txt s
  d="$base/wl"
  if [ "$sub" = root_symlink ]; then d="$base/real"; fi
  mkdir -p "$d/h13"
  printf '{}\n' >"$d/h13/2026-01-01.jsonl"
  case "$sub" in
    suelto) printf 'x\n' >"$d/suelto.txt" ;;
    git_vacio) mkdir "$d/.git" ;;
    otro_dir) mkdir "$d/otro" ;;
    symlink_en_eff) ln -s nada "$d/h13/2026-01-02.jsonl" ;;
    subdir_en_eff) mkdir "$d/h13/sub" ;;
    fichero_en_eff) printf 'x\n' >"$d/h13/x.txt" ;;
    root_symlink) ln -s real "$base/wl" ;;
  esac
  before="$(tree_hash "$base/wl")"; before_real="$(tree_hash "$base/real")"
  i13 h13 "file://$base/r.git" --host h13
  [ "$i13_rc" -eq 1 ] || fail "13.4 $sub: rc esperado 1, obtenido $i13_rc ($i13_err)"
  printf '%s\n' "$i13_err" | grep -qF 'ya existe y no está vacío' || fail "13.4 $sub: mensaje ($i13_err)"
  [ -z "$i13_out" ] || fail "13.4 $sub: stdout no vacío"
  no_cfg13 || fail "13.4 $sub: se escribió config"
  no_tmp13 || fail "13.4 $sub: quedó un temporal"
  if ! { [ "$(tree_hash "$base/wl")" = "$before" ] && [ "$(tree_hash "$base/real")" = "$before_real" ]; }; then fail "13.4 $sub: el árbol cambió"; fi
done
pass "13.4 no adoptable (7 subcasos): rc=1, mensaje, sin config/temporales, intacto"

# 13.5 host distinto: datos de maquinaA con --host maquinaB.
mk13 e
seed13 main seed.txt s
mkdir -p "$base/wl/maquinaA"
printf '{}\n' >"$base/wl/maquinaA/2026-01-01.jsonl"
before="$(tree_hash "$base/wl")"
i13 maquinaB "file://$base/r.git" --host maquinaB
[ "$i13_rc" -eq 1 ] || fail "13.5: rc esperado 1, obtenido $i13_rc"
printf '%s\n' "$i13_err" | grep -qF 'hay datos locales de maquinaA/; usa --host maquinaA o WORKLOG_HOST=maquinaA' || fail "13.5: pista ($i13_err)"
if ! { no_cfg13 && no_tmp13; }; then fail "13.5: config o temporal"; fi
[ "$(tree_hash "$base/wl")" = "$before" ] || fail "13.5: árbol cambió"
pass "13.5 host distinto: rc=1 con pista, intacto"

# 13.6 clone fallido: rc propagado de git, sin config ni temporal, intacto.
for sub in adoptable no_adoptable; do
  mk13 "f_$sub"
  mkdir -p "$base/wl/h13"
  printf '{}\n' >"$base/wl/h13/2026-01-01.jsonl"
  if [ "$sub" = no_adoptable ]; then printf 'x\n' >"$base/wl/suelto"; fi
  before="$(tree_hash "$base/wl")"
  "$real_git" clone -q -- "file://$base/inexistente.git" "$base/probe" 2>/dev/null; git_rc=$?
  [ "$git_rc" -ne 0 ] || fail "13.6: la sonda de clone debía fallar"
  i13 h13 "file://$base/inexistente.git" --host h13
  [ "$i13_rc" -ne 0 ] || fail "13.6 $sub: rc 0 con clone fallido"
  [ "$sub" = no_adoptable ] || [ "$i13_rc" -eq "$git_rc" ] || fail "13.6 $sub: rc $i13_rc no es el de git ($git_rc)"
  if ! { no_cfg13 && no_tmp13; }; then fail "13.6 $sub: config o temporal"; fi
  [ "$(tree_hash "$base/wl")" = "$before" ] || fail "13.6 $sub: árbol cambió"
done
pass "13.6 clone fallido: rc de git propagado (adoptable), sin config/temporal, intacto"

# 13.7 colisión remota: el remoto ya contiene <equipo>/.
for sub in otro_fichero mismo_fichero; do
  mk13 "g_$sub"
  if [ "$sub" = otro_fichero ]; then seed13 main h13/otro.jsonl '{"r":1}'; else seed13 main "h13/$today.jsonl" '{"remoto":1}'; fi
  mkdir -p "$base/wl/h13"
  printf '{"local":1}\n' >"$base/wl/h13/$today.jsonl"
  before="$(tree_hash "$base/wl")"; refs="$("$real_git" -C "$base/r.git" for-each-ref)"
  i13 h13 "file://$base/r.git" --host h13
  [ "$i13_rc" -eq 1 ] || fail "13.7 $sub: rc esperado 1, obtenido $i13_rc ($i13_err)"
  printf '%s\n' "$i13_err" | grep -qF 'el remoto ya contiene' || fail "13.7 $sub: mensaje ($i13_err)"
  if ! { no_cfg13 && no_tmp13; }; then fail "13.7 $sub: config o temporal"; fi
  [ "$(tree_hash "$base/wl")" = "$before" ] || fail "13.7 $sub: datos locales cambiaron"
  [ "$("$real_git" -C "$base/r.git" for-each-ref)" = "$refs" ] || fail "13.7 $sub: refs del remoto cambiaron"
done
pass "13.7 colisión remota: rc=1 sin merge, local y remoto intactos"

# 13.8 temporales residuales SIN marcador (o con marcador pero sin clone/<equipo>) no bloquean y no se tocan.
mk13 h
add13 h13 "e8"
mkdir -p "$base/.wl.init-zzz" "$base/.wl.init-yyy"
printf 'x\n' >"$base/.wl.init-zzz/junk"
printf 'h13\n' >"$base/.wl.init-yyy/ADOPTING"
res_before="$(tree_hash "$base/.wl.init-zzz")$(tree_hash "$base/.wl.init-yyy")"
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 0 ] || fail "13.8: rc $i13_rc ($i13_err)"
if ! { [ -d "$base/wl/h13" ] && [ -d "$base/wl/.git" ]; }; then fail "13.8: no adoptó"; fi
[ "$(tree_hash "$base/.wl.init-zzz")$(tree_hash "$base/.wl.init-yyy")" = "$res_before" ] || fail "13.8: el residuo cambió"
[ "$(find "$base" -maxdepth 1 -name '.wl.init-*' | wc -l)" -eq 2 ] || fail "13.8: temporales inesperados"
pass "13.8 residuo sin marcador no bloquea ni se modifica"

# 13.9 datos en tránsito fabricados: root vacío + .wl.init-x/ADOPTING + clone/<equipo>/f.jsonl.
mk13 i
mkdir -p "$base/wl" "$base/.wl.init-x/clone/h13"
printf 'h13\n' >"$base/.wl.init-x/ADOPTING"
printf '{"x":1}\n' >"$base/.wl.init-x/clone/h13/f.jsonl"
res_before="$(tree_hash "$base/.wl.init-x")"
i13 h13 "file://$base/r.git" --host h13
[ "$i13_rc" -eq 1 ] || fail "13.9: rc esperado 1, obtenido $i13_rc ($i13_err)"
printf '%s\n' "$i13_err" | grep -qF "$base/.wl.init-x" || fail "13.9: el mensaje no cita la ruta ($i13_err)"
[ -z "$(ls -A "$base/wl")" ] || fail "13.9: root dejó de estar vacío (¿clonó?)"
no_cfg13 || fail "13.9: config escrita"
[ "$(tree_hash "$base/.wl.init-x")" = "$res_before" ] || fail "13.9: f.jsonl o el temporal cambiaron"
pass "13.9 datos en tránsito: rc=1 citando la ruta, sin clone, intactos"

# 14. Condiciones de seguridad (C-01..C-04), deterministas: el test sustituye os.rename/os.replace
#     dentro de un proceso python que importa wl como módulo; wl no contiene código de prueba.
drv14="$tmp_dir/drv14.py"
cat >"$drv14" <<'PY'
import atexit, errno, importlib.machinery, importlib.util, os, sys

src, mode, url = sys.argv[1:4]
loader = importlib.machinery.SourceFileLoader("wl_mod", src)
spec = importlib.util.spec_from_loader("wl_mod", loader)
wl = importlib.util.module_from_spec(spec)
loader.exec_module(wl)  # el guard __main__ evita ejecutar main()

real_rename = os.rename
calls = []
atexit.register(lambda: print(f"driver: os.rename llamadas={len(calls)}", file=sys.stderr))

def second_rename_fails(before=None):
    def fake(a, b, *args, **kw):
        calls.append((str(a), str(b)))
        if len(calls) == 2:
            if before:
                before()
            raise OSError(errno.EIO, "fallo simulado en el segundo rename")
        return real_rename(a, b, *args, **kw)
    return fake

def recreate():
    d = os.path.join(os.environ["WORKLOG_DIR"], "h14")
    os.makedirs(d)
    with open(os.path.join(d, "nuevo.jsonl"), "w") as f:
        f.write('{"nuevo":1}\n')

if mode == "b_rollback_ok":
    os.rename = second_rename_fails()
elif mode == "b_concurrent":
    os.rename = second_rename_fails(recreate)
elif mode == "replace_fail":
    def boom(a, b, *args, **kw):
        raise OSError(errno.EIO, "fallo simulado en os.replace")
    os.replace = boom
else:
    sys.exit("modo desconocido")

wl.main(["init", url, "--host", "h14"])
PY
run14() { # run14 MODO: usa $base; deja run14_rc/out/err
  run14_out="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h14 python3 "$drv14" "$wl_src" "$1" "file://$base/r.git" 2>"$tmp_dir/err14")"
  run14_rc=$?
  run14_err="$(cat "$tmp_dir/err14")"
}

# 14a: el segundo rename falla y el rollback tiene éxito -> original restaurado.
mk13 j
add13 h14 "e14a"
before="$(tree_hash "$base/wl")"
run14 b_rollback_ok
[ "$run14_rc" -eq 1 ] || fail "14a: rc esperado 1, obtenido $run14_rc ($run14_err)"
printf '%s\n' "$run14_err" | grep -q '^wl: ' || fail "14a: stderr sin wl: ($run14_err)"
printf '%s\n' "$run14_err" | grep -qF 'driver: os.rename llamadas=3' || fail "14a: debían ser 3 renames (A, B fallido, rollback) ($run14_err)"
[ "$(tree_hash "$base/wl")" = "$before" ] || fail "14a: el original no quedó idéntico"
no_tmp13 || fail "14a: quedó un temporal"
no_cfg13 || fail "14a: quedó config"
pass "14a rename B falla + rollback ok: rc=1, original idéntico, sin temporal ni config"

# 14b: el segundo rename falla tras recrear root/<equipo> -> el rollback falla; se conservan ambos conjuntos.
mk13 k
add13 h14 "e14b"
orig="$(tree_hash "$base/wl/h14")"
run14 b_concurrent
[ "$run14_rc" -eq 1 ] || fail "14b: rc esperado 1, obtenido $run14_rc ($run14_err)"
printf '%s\n' "$run14_err" | grep -qF 'driver: os.rename llamadas=3' || fail "14b: debían ser 3 renames (A, B fallido, rollback) ($run14_err)"
t14="$(find "$base" -maxdepth 1 -name '.wl.init-*')"
if ! { [ "$(printf '%s\n' "$t14" | wc -l)" -eq 1 ] && [ -n "$t14" ]; }; then fail "14b: debe quedar exactamente un temporal ($t14)"; fi
[ "$(tree_hash "$t14/clone/h14")" = "$orig" ] || fail "14b: los datos originales no se conservaron en T/clone/h14"
if ! { [ "$(ls -A "$base/wl/h14")" = "nuevo.jsonl" ] && [ "$(cat "$base/wl/h14/nuevo.jsonl")" = '{"nuevo":1}' ]; }; then fail "14b: los datos nuevos de root no se conservaron"; fi
[ "$(cat "$t14/ADOPTING")" = "h14" ] || fail "14b: marcador ausente o incorrecto"
printf '%s\n' "$run14_err" | grep -qF "$t14/clone/h14" || fail "14b: el mensaje no cita los datos originales ($run14_err)"
printf '%s\n' "$run14_err" | grep -qF "$base/wl/h14" || fail "14b: el mensaje no cita los datos nuevos ($run14_err)"
no_cfg13 || fail "14b: quedó config"
pass "14b rollback imposible: rc=1, se conservan ambos conjuntos y el mensaje cita ambas rutas"

# 14c: a continuación, wl init real (CLI) aunque root/<equipo> exista -> rc=1 por datos pendientes, nada se toca.
before="$(tree_hash "$base")"
i13 h14 "file://$base/r.git" --host h14
[ "$i13_rc" -eq 1 ] || fail "14c: rc esperado 1, obtenido $i13_rc ($i13_err)"
printf '%s\n' "$i13_err" | grep -qF "$t14" || fail "14c: el mensaje no cita el temporal ($i13_err)"
[ -z "$i13_out" ] || fail "14c: stdout no vacío"
[ "$(tree_hash "$base")" = "$before" ] || fail "14c: init tocó el estado pendiente"
pass "14c init se niega con datos pendientes y no toca nada"

# 14d: os.replace(host.tmp, cfg) falla tras adoptar -> sin éxito, datos adoptados, recuperación de config exacta.
mk13 l
add13 h14 "e14d"
orig="$(tree_hash "$base/wl/h14")"
run14 replace_fail
[ "$run14_rc" -eq 1 ] || fail "14d: rc esperado 1, obtenido $run14_rc ($run14_err)"
printf '%s\n' "$run14_out" | grep -q 'listo:' && fail "14d: stdout con 'listo:'"
printf '%s\n' "$run14_err" | grep -qF 'sin confirmar; wl sync las publica' && fail "14d: nota de adopción satisfactoria"
[ "$(tree_hash "$base/wl/h14")" = "$orig" ] || fail "14d: los datos adoptados cambiaron o se deshizo la adopción"
[ -d "$base/wl/.git" ] || fail "14d: no hay .git (adopción deshecha)"
[ "$("$real_git" -C "$base/wl" status --porcelain)" = "?? h14/" ] || fail "14d: status inesperado"
printf '%s\n' "$run14_err" | grep -qF "printf '%s\\n' 'h14' > '$base/cfg/worklog/host'" || fail "14d: falta el comando exacto de recuperación ($run14_err)"
[ ! -e "$base/cfg/worklog/host" ] || fail "14d: la config no debía existir"
pass "14d falla la config tras adoptar: rc=1, sin éxito, datos adoptados, comando de recuperación exacto"

# 14e: exclusiones de Git en el remoto -> rechazo, original intacto.
for pat in '*.jsonl' 'h14*/'; do
  mk13 "m$(printf '%s' "$pat" | tr -c 'a-z0-9' _)"
  seed13 main .gitignore "$pat"
  add13 h14 "e14e"
  before="$(tree_hash "$base/wl")"
  i13 h14 "file://$base/r.git" --host h14
  [ "$i13_rc" -eq 1 ] || fail "14e '$pat': rc esperado 1, obtenido $i13_rc ($i13_err)"
  printf '%s\n' "$i13_err" | grep -qi 'exclu' || fail "14e '$pat': el mensaje no habla de exclusiones ($i13_err)"
  if ! { no_tmp13 && no_cfg13; }; then fail "14e '$pat': temporal o config"; fi
  [ "$(tree_hash "$base/wl")" = "$before" ] || fail "14e '$pat': original cambió"
done
pass "14e .gitignore del remoto que excluye los datos: rc=1, intacto, sin temporal ni config"

# 14f (caracterización): el remoto solo tiene otra rama -> init adopta (rc=0); wl sync falla en el pull como 12d (rc=2).
mk13 n
seed13 otra seed.txt s
add13 h14 "e14f"
i13 h14 "file://$base/r.git" --host h14
[ "$i13_rc" -eq 0 ] || fail "14f: init rc $i13_rc ($i13_err)"
sync14_err="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h14 wl sync 2>&1 >/dev/null)"; sync14_rc=$?
[ "$sync14_rc" -eq 2 ] || fail "14f: sync rc esperado 2, obtenido $sync14_rc ($sync14_err)"
pass "14f remoto con otra rama: init rc=0, sync rc=2 (caracterización, como 12d)"

# 15. add: formato de stdout, JSONL y errores (solo lo que 1-8 no cubren).
w15="$tmp_dir/wl15"
add15() { WORKLOG_DIR="$w15" WORKLOG_HOST=h15 wl "$@"; }
out="$(add15 "primera entrada")" || fail "15: add falló"
printf '%s\n' "$out" | grep -Eq '^[0-9]{2}:[0-9]{2} ✅ hecho · primera entrada$' || fail "15: formato de stdout ($out)"
f15="$w15/h15/$today.jsonl"
python3 -I - "$f15" <<'PY' || fail "15: el JSONL no tiene exactamente id/ts/host/tipo/texto válidos"
import json, re, sys
from datetime import datetime
lines = open(sys.argv[1], encoding="utf-8").read().splitlines()
assert len(lines) == 1, lines
e = json.loads(lines[0])
assert set(e) == {"id", "ts", "host", "tipo", "texto"}, sorted(e)
assert re.fullmatch(r"[0-9a-f]{12}", e["id"]), e["id"]
assert datetime.fromisoformat(e["ts"]).tzinfo is not None, e["ts"]
assert (e["host"], e["tipo"], e["texto"]) == ("h15", "hecho", "primera entrada"), e
PY
out="$(add15 -l "algo aprendido")"; printf '%s\n' "$out" | grep -Eq '^[0-9]{2}:[0-9]{2} 💡 aprendizaje · algo aprendido$' || fail "15: -l ($out)"
out="$(add15 -d "algo decidido")"; printf '%s\n' "$out" | grep -Eq '^[0-9]{2}:[0-9]{2} ⚖️ decision · algo decidido$' || fail "15: -d ($out)"
out="$(add15 -b "algo bloqueado")"; printf '%s\n' "$out" | grep -Eq '^[0-9]{2}:[0-9]{2} ⛔ bloqueo · algo bloqueado$' || fail "15: -b ($out)"
[ "$(wc -l <"$f15" | tr -d ' ')" -eq 4 ] || fail "15: se esperaban 4 líneas"
before="$(tree_hash "$w15")"
for empty in "" "   "; do
  out="$(add15 "$empty" 2>"$tmp_dir/err15")"; rc=$?
  if ! { [ "$rc" -eq 1 ] && [ -z "$out" ] && grep -q '^wl: falta el texto' "$tmp_dir/err15"; }; then fail "15: texto vacío '$empty' (rc=$rc)"; fi
done
out="$(add15 -l 2>/dev/null)"; [ $? -eq 1 ] || fail "15: flag sin texto debe devolver 1"
[ "$(tree_hash "$w15")" = "$before" ] || fail "15: un texto vacío escribió algo"
out="$(WORKLOG_DIR="$tmp_dir/wl15bad" WORKLOG_HOST="a b" wl "texto" 2>"$tmp_dir/err15")"; rc=$?
if ! { [ "$rc" -eq 1 ] && [ -z "$out" ] && grep -q 'nombre de equipo no válido' "$tmp_dir/err15"; }; then fail "15: host inválido (rc=$rc)"; fi
[ ! -e "$tmp_dir/wl15bad" ] || fail "15: host inválido escribió datos"
pass "15 add: formato HH:MM, JSONL de 5 campos, -l/-d/-b, texto vacío y host inválido rc=1 sin escribir"

# 16. lectura tolerante (wl today). TZ=UTC fija para que el orden no dependa de la zona local.
w16="$tmp_dir/wl16"
mkdir -p "$w16/h16"
d16="$(TZ=UTC date +%F)"
{
  printf '{"id":"t16000000001","ts":"%sT10:00:00+00:00","host":"h16","tipo":"hecho","texto":"A"}\n' "$d16"
  printf 'esto no es json\n'
  printf '\n'
  printf '{"id":"t16000000002","ts":"%sT09:00:00+00:00","host":"h16","tipo":"hecho","texto":"B"}\n' "$d16"
  printf '{"id":"t16000000003","ts":"%sT13:00:00+00:00","host":"h16","texto":"sin tipo"}\n' "$d16"
  printf '{"id":"t16000000004","ts":"%sT14:00:00+00:00","host":"h16","tipo":"hecho","texto":5}\n' "$d16"
  printf '{"id":"t16000000005","ts":"ayer","host":"h16","tipo":"hecho","texto":"ts roto"}\n'
  printf '{"id":"t16000000006","ts":"%sT12:00:00+00:00","host":"h16","tipo":"hecho","texto":"C","extra":1}\n' "$d16"
  printf '{"id":"t16000000007","ts":"%sT11:00:00","host":"h16","tipo":"hecho","texto":"D"}\n' "$d16"
} >"$w16/h16/$d16.jsonl"
out="$(TZ=UTC WORKLOG_DIR="$w16" wl today 2>"$tmp_dir/err16")"; rc=$?
[ "$rc" -eq 0 ] || fail "16: today rc $rc"
exp_out="$(printf '09:00 ✅ hecho · B [h16]\n10:00 ✅ hecho · A [h16]\n11:00 ✅ hecho · D [h16]\n12:00 ✅ hecho · C [h16]')"
[ "$out" = "$exp_out" ] || fail "16: salida inesperada: $out"
exp_err="$(printf 'wl: aviso: línea inválida h16/%s.jsonl:2\nwl: aviso: línea inválida h16/%s.jsonl:5\nwl: aviso: línea inválida h16/%s.jsonl:6\nwl: aviso: línea inválida h16/%s.jsonl:7' "$d16" "$d16" "$d16" "$d16")"
[ "$(cat "$tmp_dir/err16")" = "$exp_err" ] || fail "16: avisos inesperados: $(cat "$tmp_dir/err16")"
pass "16 lectura tolerante: válidas ordenadas, 4 avisos con número de línea, ninguno por la línea en blanco"

# 17. contrato vigente de init (argumentos y errores).
out="$(WORKLOG_DIR="$tmp_dir/wl17" wl init --host 2>"$tmp_dir/err17")"; rc=$?
if ! { [ "$rc" -eq 1 ] && grep -qF 'wl: --host requiere un nombre' "$tmp_dir/err17"; }; then fail "17: init --host (rc=$rc)"; fi
out="$(WORKLOG_DIR="$tmp_dir/wl17" wl init "file://$tmp_dir/x.git" extra 2>"$tmp_dir/err17")"; rc=$?
if ! { [ "$rc" -eq 1 ] && grep -qF 'wl: argumento desconocido: extra' "$tmp_dir/err17"; }; then fail "17: argumento extra (rc=$rc)"; fi
out="$(WORKLOG_DIR="$tmp_dir/wl17" XDG_CONFIG_HOME="$tmp_dir/cfg17" wl init "file://$tmp_dir/x.git" --host 'a b' 2>"$tmp_dir/err17")"; rc=$?
if ! { [ "$rc" -eq 1 ] && grep -qF "wl: nombre de equipo no válido" "$tmp_dir/err17"; }; then fail "17: --host inválido (rc=$rc)"; fi
if ! { [ ! -e "$tmp_dir/wl17" ] && [ ! -e "$tmp_dir/cfg17" ]; }; then fail "17: --host inválido creó WORKLOG_DIR o config"; fi
WORKLOG_DIR="$tmp_dir/wl17" XDG_CONFIG_HOME="$tmp_dir/cfg17" wl init "file://$tmp_dir/inexistente.git" --host h17 >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] || fail "17: clone fallido devolvió 0"
[ ! -e "$tmp_dir/cfg17/worklog/host" ] || fail "17: clone fallido escribió config"
pass "17 init: --host sin nombre, argumento desconocido, host inválido sin crear nada, clone fallido sin config"

# 18. daily positivo sobre un vault sintético bajo el tmp (nunca notas reales).
w18="$tmp_dir/wl18"
mkdir -p "$w18/h18"
{
  # shellcheck disable=SC2016 # los backticks son texto literal del JSON
  printf '{"id":"d18000000001","ts":"2026-10-19T09:05:00+02:00","host":"h18","tipo":"hecho","texto":"a <!-- b --> c `x`"}\n'
  printf '{"id":"d18000000002","ts":"2026-10-19T08:00:00+02:00","host":"h18","tipo":"hecho","texto":"primera"}\n'
} >"$w18/h18/2026-10-19.jsonl"
# shellcheck disable=SC2016 # los backticks son texto literal del bloque
block18="$(printf '<!-- worklog:start -->\n## 🧾 Registro\n\n- 08:00 ✅ **hecho** · primera `h18`\n- 09:05 ✅ **hecho** · a &lt;!-- b --&gt; c '"'"'x'"'"' `h18`\n<!-- worklog:end -->')"
v18() { # v18 NOMBRE CONTENIDO(printf): crea $tmp/vault18NOMBRE/DAILY/2026-10-19.md
  mkdir -p "$tmp_dir/vault18$1/DAILY"
  printf '%b' "$2" >"$tmp_dir/vault18$1/DAILY/2026-10-19.md"
}
d18() { WORKLOG_DIR="$w18" wl daily --vault "$tmp_dir/vault18$1" --date 2026-10-19; }
n18() { printf '%s' "$tmp_dir/vault18$1/DAILY/2026-10-19.md"; }

# (a) sin marcadores: bloque tras rstrip + línea en blanco
v18 a '# daily\n\ntexto\n\n\n'
out="$(d18 a 2>&1)" || fail "18a: rc≠0 ($out)"
[ "$out" = "$(realpath "$(n18 a)"): 2 entradas" ] || fail "18a: stdout ($out)"
printf '# daily\n\ntexto\n\n%s\n' "$block18" | cmp -s - "$(n18 a)" || fail "18a: contenido inesperado"
# (b) con marcadores y contenido viejo: solo cambia el bloque; segunda ejecución idempotente
v18 b 'antes\n<!-- worklog:start -->\nviejo\n<!-- worklog:end -->\ndespués\n'
d18 b >/dev/null 2>&1 || fail "18b: rc≠0"
printf 'antes\n%s\ndespués\n' "$block18" | cmp -s - "$(n18 b)" || fail "18b: contenido inesperado"
h18="$(sha256sum <"$(n18 b)")"
out="$(d18 b 2>&1)" || fail "18b: segunda ejecución rc≠0"
if ! { [ "$out" = "sin cambios" ] && [ "$(sha256sum <"$(n18 b)")" = "$h18" ]; }; then fail "18b: la segunda ejecución no es idempotente ($out)"; fi
# (c) escapes dentro del bloque
grep -qF "a &lt;!-- b --&gt; c 'x'" "$(n18 b)" || fail "18c: escapes de <!--, --> y backtick"
if ! { [ "$(grep -cF '<!-- worklog:start -->' "$(n18 b)")" -eq 1 ] && [ "$(grep -cF '<!-- worklog:end -->' "$(n18 b)")" -eq 1 ]; }; then fail "18c: el texto reprodujo un marcador"; fi
# (d) marcadores incompletos o desordenados
v18 d1 'x\n<!-- worklog:start -->\ny\n'
v18 d2 'x\n<!-- worklog:end -->\ny\n<!-- worklog:start -->\n'
for k in d1 d2; do
  before="$(sha256sum <"$(n18 $k)")"
  out="$(d18 $k 2>"$tmp_dir/err18")"; rc=$?
  if ! { [ "$rc" -eq 1 ] && [ -z "$out" ] && grep -q '^wl: marcadores de worklog incompletos o desordenados' "$tmp_dir/err18"; }; then fail "18d $k: rc=$rc"; fi
  [ "$(sha256sum <"$(n18 $k)")" = "$before" ] || fail "18d $k: la nota cambió"
done
# (e) CRLF con marcadores
v18 e 'antes\r\n<!-- worklog:start -->\r\nviejo\r\n<!-- worklog:end -->\r\ndespués\r\n'
d18 e >/dev/null 2>&1 || fail "18e: rc≠0"
python3 -I - "$(n18 e)" <<'PY' || fail "18e: hay \\n sin \\r o falta el bloque"
import sys
b = open(sys.argv[1], "rb").read()
assert b.count(b"\n") == b.count(b"\r\n") > 0
assert b"primera" in b and b"viejo" not in b and b.startswith(b"antes\r\n") and b.endswith(b"despu\xc3\xa9s\r\n")
PY
# (f) CRLF sin marcadores
v18 f '# d\r\n\r\ntexto\r\n'
d18 f >/dev/null 2>&1 || fail "18f: rc≠0"
python3 -I - "$(n18 f)" <<'PY' || fail "18f: bloque no añadido en CRLF"
import sys
b = open(sys.argv[1], "rb").read()
assert b.count(b"\n") == b.count(b"\r\n") > 0
assert b.startswith(b"# d\r\n\r\ntexto\r\n\r\n<!-- worklog:start -->\r\n") and b.endswith(b"<!-- worklog:end -->\r\n")
PY
# (g) symlink: el destino se actualiza, el enlace se conserva, no queda .tmp
mkdir -p "$tmp_dir/vault18g/real" "$tmp_dir/vault18g/DAILY"
printf '# real\n' >"$tmp_dir/vault18g/real/2026-10-19.md"
ln -s ../real/2026-10-19.md "$tmp_dir/vault18g/DAILY/2026-10-19.md"
out="$(d18 g 2>&1)" || fail "18g: rc≠0 ($out)"
[ -L "$tmp_dir/vault18g/DAILY/2026-10-19.md" ] || fail "18g: el enlace dejó de ser enlace"
grep -qF '<!-- worklog:start -->' "$tmp_dir/vault18g/real/2026-10-19.md" || fail "18g: el destino no contiene el bloque"
[ "$out" = "$(realpath "$tmp_dir/vault18g/real/2026-10-19.md"): 2 entradas" ] || fail "18g: stdout no muestra la ruta resuelta ($out)"
[ -z "$(find "$tmp_dir/vault18g" -name '*.tmp')" ] || fail "18g: quedó un .tmp"
pass "18 daily: sin marcadores, con marcadores (idempotente), escapes, marcadores rotos, CRLF y symlink"

# 19. sync con remoto inalcanzable (12e). Simula SOLO un fallo inmediato de transporte (ruta file:// inexistente).
#     NO acredita timeouts, DNS, red caída, autenticación ni WSL2. No se afirma si hubo o no pull.
"$real_git" init -q --bare -b main "$tmp_dir/r12e.git"
init12 e r12e
WORKLOG_DIR="$tmp_dir/wl12e" WORKLOG_HOST="h12e" wl "entrada 12e" >/dev/null || fail "19: no se pudo registrar la entrada"
"$real_git" -C "$tmp_dir/wl12e" remote set-url origin "file://$tmp_dir/inexistente.git"
sync12 e
[ "$sync12_rc" -eq 2 ] || fail "19: rc esperado 2, obtenido $sync12_rc ($sync12_err)"
[ -z "$sync12_out" ] || fail "19: stdout no vacío ($sync12_out)"
if ! { printf '%s\n' "$sync12_err" | grep -q '^wl: ' && printf '%s\n' "$sync12_err" | grep -q 'a salvo en local'; }; then fail "19: stderr ($sync12_err)"; fi
printf '%s\n%s\n' "$sync12_out" "$sync12_err" | grep -q 'sincronizado' && fail "19: dijo 'sincronizado'"
[ "$("$real_git" -C "$tmp_dir/wl12e" rev-list --count HEAD)" -eq 1 ] || fail "19: debe haber 1 commit local"
[ "$(wc -l <"$tmp_dir/wl12e/h12e/$today.jsonl" | tr -d ' ')" -eq 1 ] || fail "19: JSONL no conservado"
[ -z "$("$real_git" -C "$tmp_dir/wl12e" status --porcelain)" ] || fail "19: el árbol de trabajo no quedó limpio"
"$real_git" -C "$tmp_dir/wl12e" remote set-url origin "file://$tmp_dir/r12e.git"
sync12 e
if ! { [ "$sync12_rc" -eq 0 ] && [ "$sync12_out" = "sincronizado" ]; }; then fail "19: recuperación rc=$sync12_rc ($sync12_err)"; fi
pass "19 sync con remoto inalcanzable: rc=2 'a salvo en local', 1 commit local; recuperación rc=0"

# 20. F2.1: interrupción u error en/tras el rename A nunca borra los datos originales.
#     El parche ejecuta el os.rename REAL de A y después lanza la excepción (determinista).
drv20="$tmp_dir/drv20.py"
cat >"$drv20" <<'PY'
import errno, importlib.machinery, importlib.util, os, sys

src, mode, url = sys.argv[1:4]
loader = importlib.machinery.SourceFileLoader("wl_mod", src)
spec = importlib.util.spec_from_loader("wl_mod", loader)
wl = importlib.util.module_from_spec(spec)
loader.exec_module(wl)

real_rename = os.rename
calls = []

def patched(after):
    def fake(a, b, *args, **kw):
        calls.append((str(a), str(b)))
        if len(calls) == 1:  # A
            after(a, b, args, kw)
        return real_rename(a, b, *args, **kw)
    return fake

def moved_then(exc):
    def f(a, b, args, kw):
        real_rename(a, b, *args, **kw)
        raise exc
    return f

def fails_unmoved(a, b, args, kw):
    raise OSError(errno.EIO, "fallo simulado en A sin mover")

if mode == "a_interrupt":
    os.rename = patched(moved_then(KeyboardInterrupt()))
elif mode == "b_unmoved":
    os.rename = patched(fails_unmoved)
elif mode == "c_moved_oserror":
    os.rename = patched(moved_then(OSError(errno.EIO, "fallo simulado tras mover")))
else:
    sys.exit("modo desconocido")

wl.main(["init", url, "--host", "h20"])
PY
run20() { # run20 MODO: usa $base; deja run20_rc/out/err
  run20_out="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h20 python3 "$drv20" "$wl_src" "$1" "file://$base/r.git" 2>"$tmp_dir/err20")"
  run20_rc=$?
  run20_err="$(cat "$tmp_dir/err20")"
}

# 20a: A se completa y acto seguido KeyboardInterrupt -> los datos siguen en T/clone/h20.
mk13 zm
add13 h20 "e20a"
orig="$(tree_hash "$base/wl/h20")"
run20 a_interrupt
[ "$run20_rc" -ne 0 ] || fail "20a: el proceso no debía terminar con éxito"
printf '%s\n' "$run20_out" | grep -q 'listo:' && fail "20a: stdout con 'listo:'"
t20="$(find "$base" -maxdepth 1 -name '.wl.init-*')"
if ! { [ -n "$t20" ] && [ "$(printf '%s\n' "$t20" | wc -l)" -eq 1 ]; }; then fail "20a: debe quedar exactamente un temporal ($t20)"; fi
[ "$(tree_hash "$t20/clone/h20")" = "$orig" ] || fail "20a: los datos originales no se conservaron en T/clone/h20"
[ "$(cat "$t20/ADOPTING")" = "h20" ] || fail "20a: marcador ausente o incorrecto"
no_cfg13 || fail "20a: quedó config"
before="$(tree_hash "$base")"
i13 h20 "file://$base/r.git" --host h20
[ "$i13_rc" -eq 1 ] || fail "20a: wl init posterior: rc esperado 1, obtenido $i13_rc ($i13_err)"
printf '%s\n' "$i13_err" | grep -qF "$t20" || fail "20a: el mensaje no cita el temporal ($i13_err)"
[ "$(tree_hash "$base")" = "$before" ] || fail "20a: init posterior tocó el estado pendiente"
pass "20a A completado + KeyboardInterrupt: datos conservados, temporal y marcador intactos, init posterior se niega"

# 20b: A falla con OSError sin mover -> datos en root, temporal limpiado, rc=1.
mk13 zn
add13 h20 "e20b"
before="$(tree_hash "$base/wl")"
run20 b_unmoved
[ "$run20_rc" -eq 1 ] || fail "20b: rc esperado 1, obtenido $run20_rc ($run20_err)"
printf '%s\n' "$run20_err" | grep -q '^wl: ' || fail "20b: stderr sin wl: ($run20_err)"
[ "$(tree_hash "$base/wl")" = "$before" ] || fail "20b: el original no quedó idéntico"
no_tmp13 || fail "20b: quedó un temporal"
no_cfg13 || fail "20b: quedó config"
pass "20b A falla sin mover: rc=1, original idéntico, temporal limpiado"

# 20c: A mueve y LUEGO lanza OSError (estado incierto) -> se conserva todo, con ubicaciones.
mk13 zo
add13 h20 "e20c"
orig="$(tree_hash "$base/wl/h20")"
run20 c_moved_oserror
[ "$run20_rc" -eq 1 ] || fail "20c: rc esperado 1, obtenido $run20_rc ($run20_err)"
printf '%s\n' "$run20_out" | grep -q 'listo:' && fail "20c: stdout con 'listo:'"
t20="$(find "$base" -maxdepth 1 -name '.wl.init-*')"
if ! { [ -n "$t20" ] && [ "$(printf '%s\n' "$t20" | wc -l)" -eq 1 ]; }; then fail "20c: debe quedar exactamente un temporal ($t20)"; fi
[ "$(tree_hash "$t20/clone/h20")" = "$orig" ] || fail "20c: los datos originales no se conservaron en T/clone/h20"
[ "$(cat "$t20/ADOPTING")" = "h20" ] || fail "20c: marcador ausente o incorrecto"
printf '%s\n' "$run20_err" | grep -qF "$t20/clone/h20" || fail "20c: el mensaje no cita los datos originales ($run20_err)"
printf '%s\n' "$run20_err" | grep -qF "$base/wl/h20" || fail "20c: el mensaje no cita la ubicación original ($run20_err)"
printf '%s\n' "$run20_err" | grep -qF 'recuperación manual' || fail "20c: el mensaje no indica recuperación ($run20_err)"
no_cfg13 || fail "20c: quedó config"
before="$(tree_hash "$base")"
i13 h20 "file://$base/r.git" --host h20
[ "$i13_rc" -eq 1 ] || fail "20c: wl init posterior: rc esperado 1, obtenido $i13_rc ($i13_err)"
[ "$(tree_hash "$base")" = "$before" ] || fail "20c: init posterior tocó el estado pendiente"
pass "20c A mueve y luego OSError: datos conservados, mensaje con ubicaciones y recuperación, init posterior se niega"

# 20d: el rollback satisfactorio (14a) y el fallido (14b) siguen cubiertos arriba.

# 21. F2.2: WORKLOG_HOST y --host distintos en la adopción se rechazan antes de tocar nada.
# 21a: rechazo con config previa conocida, y sin config previa.
mk13 zp
mkdir -p "$base/wl/maquinaA"
printf '{}\n' >"$base/wl/maquinaA/2026-01-01.jsonl"
mkdir -p "$base/cfg/worklog"
printf 'previo\n' >"$base/cfg/worklog/host"
before="$(tree_hash "$base/wl")"; cfg_before="$(tree_hash "$base/cfg")"
i13 maquinaA "file://$base/r.git" --host maquinaB
[ "$i13_rc" -eq 1 ] || fail "21a: rc esperado 1, obtenido $i13_rc ($i13_err)"
printf '%s\n' "$i13_err" | grep -q '^wl: ' || fail "21a: stderr sin wl: ($i13_err)"
printf '%s\n' "$i13_err" | grep -qF 'WORKLOG_HOST=maquinaA y --host maquinaB difieren' || fail "21a: mensaje ($i13_err)"
[ -z "$i13_out" ] || fail "21a: stdout no vacío"
[ "$(tree_hash "$base/wl")" = "$before" ] || fail "21a: el árbol local cambió"
[ "$(tree_hash "$base/cfg")" = "$cfg_before" ] || fail "21a: la config previa cambió"
[ "$(cat "$base/cfg/worklog/host")" = "previo" ] || fail "21a: contenido de config"
[ ! -e "$base/wl/.git" ] || fail "21a: hay .git"
no_tmp13 || fail "21a: quedó un temporal"
mk13 zq
mkdir -p "$base/wl/maquinaA"
printf '{}\n' >"$base/wl/maquinaA/2026-01-01.jsonl"
before="$(tree_hash "$base/wl")"
i13 maquinaA "file://$base/r.git" --host maquinaB
[ "$i13_rc" -eq 1 ] || fail "21a: sin config previa: rc esperado 1, obtenido $i13_rc"
no_cfg13 || fail "21a: se creó config"
[ ! -e "$base/cfg" ] || fail "21a: se creó el directorio de config"
[ "$(tree_hash "$base/wl")" = "$before" ] || fail "21a: sin config previa: árbol cambió"
[ ! -e "$base/wl/.git" ] || fail "21a: sin config previa: hay .git"
no_tmp13 || fail "21a: sin config previa: temporal"
pass "21a WORKLOG_HOST != --host en adopción: rc=1, nada modificado (con y sin config previa)"

# 21b: valores coincidentes -> adopción normal y sync posterior.
mk13 zr
add13 h21 "e21b"
i13 h21 "file://$base/r.git" --host h21
[ "$i13_rc" -eq 0 ] || fail "21b: rc esperado 0, obtenido $i13_rc ($i13_err)"
[ "$("$real_git" -C "$base/wl" status --porcelain)" = "?? h21/" ] || fail "21b: status inesperado"
[ "$(cat "$base/cfg/worklog/host")" = "h21" ] || fail "21b: config"
sync21="$(WORKLOG_DIR="$base/wl" XDG_CONFIG_HOME="$base/cfg" WORKLOG_HOST=h21 wl sync 2>&1)" || fail "21b: sync falló ($sync21)"
pass "21b valores coincidentes: adopta (?? h21/), config h21, sync rc=0"

# 21c: ruta convencional (root inexistente) con valores distintos: sin regresión.
mk13 zs
seed13 main seed.txt s
i13 hX "file://$base/r.git" --host hY
[ "$i13_rc" -eq 0 ] || fail "21c: rc esperado 0, obtenido $i13_rc ($i13_err)"
[ "$(cat "$base/cfg/worklog/host")" = "hY" ] || fail "21c: la config debe ser --host"
pass "21c init convencional con WORKLOG_HOST != --host: sin cambios (config = --host)"

# 21d: adopción con WORKLOG_HOST y sin --host: normal.
mk13 zt
add13 h21d "e21d"
i13 h21d "file://$base/r.git"
[ "$i13_rc" -eq 0 ] || fail "21d: rc esperado 0, obtenido $i13_rc ($i13_err)"
[ "$("$real_git" -C "$base/wl" status --porcelain)" = "?? h21d/" ] || fail "21d: status inesperado"
pass "21d adopción con WORKLOG_HOST y sin --host: normal"

printf 'OK\n'
