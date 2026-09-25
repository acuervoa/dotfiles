#!/usr/bin/env bash
# ai.sh — capa de comandos versionada; la lógica canónica vive en SimpleBrain/tools.

_sb_vault() { printf '%s\n' "${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"; }
_sb_tool() { printf '%s/%s\n' "$(_sb_vault)" "$1"; }

_sb_ai_session() { bash "$(_sb_tool tools/ai-session.sh)" "$@"; }

sbs() {
  if [[ "${1:-}" == "--note" ]]; then
    local note="${2:-}"
    shift 2
    [[ -n "$note" ]] || {
      printf 'Uso: sbs [--note <ruta>] <tarea>\n' >&2
      return 2
    }
    _sb_ai_session start --task "$*" --project-note "$note" --copy
  else
    [[ -n "$*" ]] || {
      printf 'Uso: sbs <tarea>\n' >&2
      return 2
    }
    _sb_ai_session start --task "$*" --copy
  fi
}

sbsb() { AI_SESSION_BENCH=1 sbs "$@"; }
sbl() {
  local note=""
  if [[ "${1:-}" == "--note" ]]; then
    note="${2:-}"
    shift 2
  fi
  [[ -n "$*" ]] || {
    printf 'Uso: sbl [--note <ruta>] <tarea>\n' >&2
    return 2
  }
  if [[ -n "$note" ]]; then
    _sb_ai_session start --task "$*" --project-note "$note" --copy --launch
  else
    _sb_ai_session start --task "$*" --copy --launch
  fi
}
sbe() {
  [[ -n "$*" ]] || {
    printf 'Uso: sbe [--from <legacy>] <resumen>\n' >&2
    return 2
  }
  _sb_ai_session end "$@" --daily --update-project-note --copy
}
sbo() { bash "$(_sb_tool tools/sbo-close-open-candidates.sh)" "$@"; }
sbclose() { bash "$(_sb_tool tools/sbclose.sh)" "$@"; }

alias afs='bash "$(_sb_tool tools/ai-flow.sh)" start'
alias afc='bash "$(_sb_tool tools/ai-flow.sh)" cycle'
alias afd='bash "$(_sb_tool tools/ai-flow.sh)" distill-run'
alias afa='bash "$(_sb_tool tools/ai-flow.sh)" distill-apply'
af() { bash "$(_sb_tool tools/ai-flow.sh)" start --task "$*"; }
afl() { bash "$(_sb_tool tools/ai-flow.sh)" start --task "$*" --launch; }
afx() { bash "$(_sb_tool tools/ai-flow.sh)" cycle --task "$1" --done "${2:-Cierre rápido}" --next "${3:-Revisar draft}"; }
afdp() { bash "$(_sb_tool tools/ai-distill-pipeline.sh)" "$@"; }
afdb() { python3 "$(_sb_tool tools/distill_bulk.py)" "$@"; }
aflastdraft() { ls -1t "$(_sb_vault)/99_META/distill-logs/"*__ai-distill-draft.md 2>/dev/null | head -n 1; }
afapplylast() {
  local draft
  draft="$(aflastdraft)" || return 1
  [[ -n "$draft" ]] || {
    printf 'No encontré drafts de distill.\n' >&2
    return 1
  }
  bash "$(_sb_tool tools/ai-flow.sh)" distill-apply --draft "$draft" --apply-note --apply-wiki-log
}

ai-session-runbook() {
  local runbook
  runbook="$(_sb_vault)/06_KNOWLEDGE/IA/ai-session — Runbook operativo.md"
  [[ -f "$runbook" ]] || {
    printf 'No se encontró el runbook: %s\n' "$runbook" >&2
    return 1
  }
  if [[ -n "${VISUAL:-${EDITOR:-}}" ]]; then
    "${VISUAL:-${EDITOR}}" "$runbook"
  elif command -v less >/dev/null 2>&1; then
    less "$runbook"
  else
    cat "$runbook"
  fi
}

ai() {
  local subcmd="${1:-}"
  if [[ "$subcmd" == end || "$subcmd" == distill ]]; then
    _sb_ai_session "$@"
  elif [[ -x "$(_sb_tool tools/ai)" ]]; then
    "$(_sb_tool tools/ai)" "$@"
  else
    printf 'Error: no se encontró %s\n' "$(_sb_tool tools/ai)" >&2
    return 1
  fi
}
