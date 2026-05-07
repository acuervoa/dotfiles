#!/usr/bin/env bash
# ai.sh - aliases y helpers para flujo AI

alias afs='ai-flow start'
alias afc='ai-flow cycle'
alias afd='ai-flow distill-run'
alias afa='ai-flow distill-apply'

af() {
  ai-flow start --task "$*"
}

afl() {
  ai-flow start --task "$*" --launch
}

afx() {
  local task="$1"
  local done_msg="${2:-Cierre rápido}"
  local next_msg="${3:-Revisar draft}"
  ai-flow cycle --task "$task" --done "$done_msg" --next "$next_msg"
}

aflastdraft() {
  ls -1t "$HOME/Vaults/SimpleBrain/99_META/distill-logs/"*__distill-draft.md 2>/dev/null | head -n 1
}

afapplylast() {
  local draft
  draft="$(aflastdraft)"
  if [ -z "$draft" ]; then
    printf 'No encontré drafts de distill.\n' >&2
    return 1
  fi
  ai-flow distill-apply --draft "$draft" --apply-note --apply-wiki-log
}
