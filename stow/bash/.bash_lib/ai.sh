#!/usr/bin/env bash
# ai.sh - Aliases y helpers para el flujo de trabajo con IA (SimpleBrain)

# --- 🚀 SESIONES RÁPIDAS (SimpleBrain) ---

_sb_session_state_dir="$HOME/.cache/simplebrain-ai"
_sb_session_state_file="$_sb_session_state_dir/last-session"

# sbs: Start Brain Session
# Uso: sbs "Tarea a realizar"
sbs() {
  if [[ -z "$*" ]]; then
    printf "Uso: sbs <descripción de la tarea>\n"
    return 1
  fi
  mkdir -p "$_sb_session_state_dir"
  local brief
  local started_at
  started_at=$(date +%Y-%m-%dT%H:%M:%S)
  brief=$(ai-session start --task "$*" --copy)
  printf '%s\n' "$brief"
  {
    printf 'task=%s\n' "$*"
    printf 'started_at=%s\n' "$started_at"
    printf 'brief=%s\n' "$brief"
  } > "$_sb_session_state_file"
}

# sbl: Start Brain Session & Launch Agent
# Uso: sbl "Tarea a realizar" (abre Claude/Codex automáticamente)
sbl() {
  if [[ -z "$*" ]]; then
    printf "Uso: sbl <descripción de la tarea>\n"
    return 1
  fi
  mkdir -p "$_sb_session_state_dir"
  local brief
  local started_at
  started_at=$(date +%Y-%m-%dT%H:%M:%S)
  brief=$(ai-session start --task "$*" --copy --launch)
  printf '%s\n' "$brief"
  {
    printf 'task=%s\n' "$*"
    printf 'started_at=%s\n' "$started_at"
    printf 'brief=%s\n' "$brief"
  } > "$_sb_session_state_file"
}

# sbe: End Brain Session (Documenta en Diario + Proyecto)
# Uso: sbe "Lo que hice" ["Siguiente paso"]
sbe() {
  local task latest_brief
  if [[ -f "$_sb_session_state_file" ]]; then
    task=$(grep '^task=' "$_sb_session_state_file" | cut -d= -f2-)
  fi
  if [[ -z "${task:-}" ]]; then
    latest_brief=$(ls -1t ~/Vaults/SimpleBrain/99_META/ai-contexts/*__ai-start.md 2>/dev/null | head -n 1)
    if [[ -z "$latest_brief" ]]; then
      printf "Error: No se encontró ninguna sesión reciente para cerrar.\n"
      return 1
    fi
    task=$(grep "Tarea:" "$latest_brief" | cut -d: -f2- | xargs)
  fi

  printf "Cerrando sesión: %s\n" "$task"
  if [[ -n "${2:-}" ]]; then
    ai-session end --task "$task" --done "$1" --next "$2" --daily --update-project-note --copy
  else
    ai-session end --task "$task" --done "$1" --daily --update-project-note --copy
  fi

  rm -f "$_sb_session_state_file"
}

# sb-lint: Ejecuta auditoría rápida del Vault
alias sb-lint='python3 ~/Vaults/SimpleBrain/tools/audit_frontmatter.py --wiki-only'

# --- 🧪 FLUJO AI-FLOW (Avanzado) ---

alias afs='ai-flow start'
alias afc='ai-flow cycle'
alias afd='ai-flow distill-run'
alias afa='ai-flow distill-apply'

# --- ⚗️ DISTILLATION (Conocimiento Durable) ---

# aflast: Localiza el último draft de destilación generado
aflastdraft() {
  ls -1t "$HOME/Vaults/SimpleBrain/99_META/distill-logs/"*__ai-distill-draft.md 2>/dev/null | head -n 1
}

# afapply: Aplica el último draft al wiki
afapplylast() {
  local draft
  draft="$(aflastdraft)"
  if [[ -z "$draft" ]]; then
    printf 'No encontré drafts de distill.\n' >&2
    return 1
  fi
  ai-flow distill-apply --draft "$draft" --apply-note --apply-wiki-log
}

# --- 🖥️ UTILIDADES Y AGENTES ---

# ia: Abre el entorno tmux para trabajo con IA
ia() {
  local session_bin="$HOME/.local/bin/ia-session"
  if [[ ! -x "$session_bin" ]]; then
    printf 'No existe o no es ejecutable: %s\n' "$session_bin" >&2
    return 1
  fi
  "$session_bin" "$@"
}

# gpt: Abre la webapp de ChatGPT
gpt() {
  if ! command -v gtk-launch >/dev/null 2>&1; then
    printf 'gtk-launch no está disponible.\n' >&2
    return 1
  fi
  gtk-launch chatgpt-webapp "$@"
}

# gpt-safe: Abre ChatGPT sin aceleración GPU (para evitar cuelgues)
gpt-safe() {
  CHATGPT_WEBAPP_DISABLE_GPU=1 gpt "$@"
}

# Codex/Agent alias rápido
alias codex-here='codex'
alias ai='ai-session'
