#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'USAGE'
Uso: scripts/run_tests.sh [opciones] [patrón]

Ejecuta todos los tests/*_test.sh y resume PASS/FAIL. Sin patrón, corre
todos; con patrón (substring), filtra por nombre de archivo.

Opciones:
  -h, --help   Muestra esta ayuda

Ejemplos:
  scripts/run_tests.sh
  scripts/run_tests.sh bash_
  scripts/run_tests.sh nvim_workflow

Códigos de salida:
  0  Todos los tests corridos pasaron
  1  Algún test falló
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

err() { printf '[ERROR] %s\n' "$*" >&2; }

PATTERN=""

while (($# > 0)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    printf '[ERROR] Opción no reconocida: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  *)
    PATTERN="$1"
    ;;
  esac
  shift
done

main() {
  shopt -s nullglob

  local -a tests=("$REPO_DIR"/tests/*_test.sh)
  if [ -n "$PATTERN" ]; then
    local -a filtered=()
    local t
    for t in "${tests[@]}"; do
      [[ "$(basename "$t")" == *"$PATTERN"* ]] && filtered+=("$t")
    done
    tests=("${filtered[@]}")
  fi

  # El release gate requiere un checkout limpio y se ejecuta como paso
  # independiente del workflow; no debe quedar invalidado por tests que
  # regeneran documentación o crean artefactos temporales.
  local -a ordinary_tests=()
  local test_path
  for test_path in "${tests[@]}"; do
    [ "$(basename "$test_path")" = "application_release_gate_test.sh" ] && continue
    ordinary_tests+=("$test_path")
  done
  tests=("${ordinary_tests[@]}")

  if [ "${#tests[@]}" -eq 0 ]; then
    warn "No se encontraron tests para ejecutar."
    return 0
  fi

  action TESTS "Ejecutando ${#tests[@]} test(s)"

  local -a failed=()
  local t name status
  for t in "${tests[@]}"; do
    name="$(basename "$t")"
    if bash "$t"; then
      status="PASS"
    else
      status="FAIL"
      failed+=("$name")
    fi
    printf '[%s] %s\n' "$status" "$name"
  done

  printf '\n'
  if [ "${#failed[@]}" -eq 0 ]; then
    info "Todos los tests pasaron (${#tests[@]}/${#tests[@]})."
    return 0
  fi

  err "Fallaron ${#failed[@]}/${#tests[@]} test(s):"
  local f
  for f in "${failed[@]}"; do
    printf '  - %s\n' "$f" >&2
  done
  return 1
}

main
