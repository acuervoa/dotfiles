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

gpt() {
  if ! command -v gtk-launch >/dev/null 2>&1; then
    printf 'gtk-launch no esta disponible.\n' >&2
    return 1
  fi

  gtk-launch chatgpt-webapp "$@"
}

ia() {
  local session_bin="$HOME/.local/bin/ia-session"

  if [[ ! -x "$session_bin" ]]; then
    printf 'No existe o no es ejecutable: %s\n' "$session_bin" >&2
    return 1
  fi

  "$session_bin" "$@"
}

ia-code() {
  local codex_cmd="codex"

  if ! command -v tmux >/dev/null 2>&1; then
    printf 'tmux no esta disponible.\n' >&2
    return 1
  fi

  if ! command -v codex >/dev/null 2>&1; then
    printf 'codex no esta disponible.\n' >&2
    return 1
  fi

  if (($# > 0)); then
    printf -v codex_cmd 'codex %q' "$1"
    shift
    if (($# > 0)); then
      local arg
      for arg in "$@"; do
        printf -v codex_cmd '%s %q' "$codex_cmd" "$arg"
      done
    fi
  fi

  tmux new-session -A -s ia "$codex_cmd"
}

gpt-safe() {
  local webapp_bin="$HOME/.local/bin/chatgpt-webapp"

  if [[ ! -x "$webapp_bin" ]]; then
    printf 'No existe o no es ejecutable: %s\n' "$webapp_bin" >&2
    return 1
  fi

  CHATGPT_WEBAPP_DISABLE_GPU=1 "$webapp_bin" "$@"
}

gpt-reset() {
  local profile_dir="$HOME/.config/chatgpt-webapp/profile"
  local expected_root="$HOME/.config/chatgpt-webapp/"

  if [[ -z "$profile_dir" || "$profile_dir" == "/" || "$profile_dir" != "$expected_root"* ]]; then
    printf 'Ruta de perfil no valida: %s\n' "$profile_dir" >&2
    return 1
  fi

  read -r -p "Borrar el perfil de chatgpt-webapp en $profile_dir? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    printf 'Cancelado.\n' >&2
    return 1
  fi

  rm -rf -- "$profile_dir" && mkdir -p -- "$profile_dir"
}

codex-here() {
  codex "$@"
}
