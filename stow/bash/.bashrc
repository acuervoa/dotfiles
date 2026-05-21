# ===========================
# ~/.bashrc - Arch
# Autor: Andrés Cuervo (ajustado por ChatGPT)
# ===========================

# Cargar sólo shells interactivas
case $- in
*i*) : ;;
*) return ;;
esac

# Asegurar entorno de login en shells no-login
if [ -z "${PROFILE_LOADED:-}" ] && [ -r "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Teclas y flujo
# - Libera Ctrl+S
stty -ixon 2>/dev/null || true
# - Edición tipo Vim en linea de comandos
#set -o vi

# Historial
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=200000
export HISTFILESIZE=400000
export HISTTIMEFORMAT='%F %T '
shopt -s histappend   # añadir en lugar de sobrescribir
shopt -s cmdhist      # almacenar lineas largas como una sola entrada
shopt -s checkwinsize # ajustar LINES y COLUMNS tras cada comando
shopt -s globstar     # ** para recursivo en glob
shopt -s extglob      # globs extendidos !(pat), +(pat), @(a|b)...
shopt -s autocd       # escribir dir = cd dir
shopt -s cdspell      # corrige pequeñas faltas al hacer cd

# Editor por defecto
export EDITOR=nvim
export VISUAL=nvim

# Composer
export COMPOSER_HOME="$HOME/.local/share/composer"
export COMPOSER_CACHE_DIR="$HOME/.cache/composer"

export PAGER="less -R"
export LESS="-RFX"

# - ble.sh (autosuggestions + syntax highlighting tipo zsh)
if [[ ! ${BLE_VERSION-} ]] && [ -f /usr/share/blesh/ble.sh ]; then
  # --noattach: deja que el resto de cosas  (atuin, prompt, etc.) se inicializen primero
  # shellcheck source=/usr/share/blesh/ble-sh disable=SC1094,SC1090,SC1091
  source /usr/share/blesh/ble.sh --noattach
fi

# Readline/completion más cómodo (case-insensitive, menú)
# Sólo si NO esta ble.sh
if [[ -z ${BLE_VERSION-} ]]; then
  bind 'set completion-ignore-case on'
  bind 'set show-all-if-ambiguous on'
  bind 'set menu-complete-display-prefix on'
  bind '"\t": menu-complete'
  bind '"\e[Z]": reverse-menu-complete' # Shift + Tab
fi

# FZF + ripgrep / fd
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git"'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f'
fi

# Opciones por defecto FZF
export FZF_DEFAULT_OPTS="
    --height 50%
    --layout=reverse
    --info=inline
    --border
    --margin=1,1
"

# Keybindings de FZF
# Lo gestionamos via ble.sh (integration/fzf-*)
# para que no pisen las bindings de atuin/ble.
# if [ -f /usr/share/fzf/key-bindings.bash ]; then
#   source /usr/share/fzf/key-bindings.bash
# fi
# if [ -f /usr/share/fzf/completion.bash ]; then
#   source /usr/share/fzf/completion.bash
# fi
# if [ -f ~/.fzf.bash ]; then
#   source ~/.fzf.bash
# fi

# bash-completion (completado más cercano a ecosistema zsh)
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# pbcopy/pbpaste
if command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
  pbcopy() { wl-copy; }
  pbpaste() { wl-paste; }
elif command -v xclip >/dev/null 2>&1; then
  pbcopy() { xclip -selection clipboard; }
  pbpaste() { xclip -selection clipboard -o; }
fi

# Iniciar herramientas

# - zoxide (cd inteligente)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# - direnv (entornos por directorio)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# - starship (prompt)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# - mise (gestor de versiones de lenguajes)
if [ -z "${MISE_INITIALIZED:-}" ]; then
  if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
    export MISE_INITIALIZED=1
  fi
fi

# - fnm (gestor de versiones de node)
if [ -z "${FNM_INITIALIZED:-}" ]; then
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell=bash)"
    export FNM_INITIALIZED=1
  fi
fi

# Desactiva titulo dentro de tmux
if [[ -n "$TMUX" ]]; then
  PROMPT_COMMAND=${PROMPT_COMMAND//\\e]0;*\a/}
  PROMPT_COMMAND=${PROMPT_COMMAND//__vte_prompt_command;/}
  PROMPT_COMMAND=${PROMPT_COMMAND//__vte_prompt_command/}
  PROMPT_COMMAND=${PROMPT_COMMAND//set-window-title/}
fi

# Carga de aliases y funciones
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"
[ -f "$HOME/.bash_lib/bash_lib.sh" ] && source "$HOME/.bash_lib/bash_lib.sh"

#-  Desduplicar PATH manteniendo el primer encuentro (orden estable)
PATH="$(/usr/bin/awk -v RS=: '!seen[$0]++{out=out (NR==1? "": ":") $0} END{print out}' <<<"$PATH")"

#- Mover Nix al final para evitar sombras
move_to_end() {
  local p="$1"
  PATH="$(/usr/bin/tr ':' '\n' <<<"$PATH" | /usr/bin/awk -v p="$p" '$0!=p{a[++n]=$0; next} {b[++m]=$0} END{for(i=1;i<=n;i++)print a[i]; for(j=1;j<=m;j++)print b[j]}' | paste -sd: -)"
}
move_to_end "$HOME/.nix-profile/bin"
move_to_end "/nix/var/nix/profiles/default/bin"

export PATH

# PATH y extras ligeros
if [ -d "$HOME/.local/share/composer/vendor/bin" ]; then
  PATH="$HOME/.local/share/composer/vendor/bin:$PATH"
fi

# -- Atuin (historial avanzado) + binding robusto de C-r ----
HIST_BACKEND="fzf" # valor por defecto si no hay Atuin
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-up-arrow)"
  HIST_BACKEND="atuin"
fi

# --- Integración Atuin/FZF con ble: un solo dueño de Ctrl-t ---
if [[ ${BLE_VERSION-} ]]; then
  case "$HIST_BACKEND" in
  atuin)
    ble-bind -x 'C-r' __atuin_history
    ;;
  *)
    if declare -F fhist >/dev/null 2>&1; then
      ble-bind -x 'C-r' fhist
    else
      ble-bind -f 'C-r' historyi
    fi
    ;;
  esac
fi

# --- Adjuntar ble.sh una vez que todo lo demás está configurado --
if [[ $- == *i* ]] && [[ ${BLE_VERSION-} ]]; then
  ble-attach
fi

# opencode (si existe)
if [ -d "$HOME/.opencode/bin" ]; then
  PATH="$HOME/.opencode/bin:$PATH"
fi

# Cargar configuraciones locales si existen
if [ -f "${HOME}/.bashrc_local" ]; then
  . "${HOME}/.bashrc_local"
fi

# OpenClaw Completion
if [ -f "$HOME/.openclaw/completions/openclaw.bash" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.openclaw/completions/openclaw.bash"
fi

# --- AI Flow shortcuts ---
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
    printf 'No encontré drafts de distill.
' >&2
    return 1
  fi
  ai-flow distill-apply --draft "$draft" --apply-note --apply-wiki-log
}

afdp() {
  # DISTILL pipeline completo: extract → classify → apply
  # Uso: afdp [--extractor claude|opencode|gemini|codex|all] [--dry-run] [--session <id>] [--min-confidence 0.6]
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  bash "$_sb_vault/tools/ai-distill-pipeline.sh" "$@"
}

afdb() {
  # DISTILL bulk: procesa todas las sesiones históricas pendientes
  # Uso: afdb [--extractor all|claude|...] [--list] [--dry-run] [--since YYYY-MM-DD] [--limit N]
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  python3 "$_sb_vault/tools/distill_bulk.py" "$@"
}

sbclose() {
  # Cierre formal de proyecto: distill → sección Cierre → archive → wiki-log → commit
  # Uso: sbclose "<patrón nombre proyecto>" [--dry-run] [--skip-distill]
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  bash "$_sb_vault/tools/sbclose.sh" "$@"
}

ai() {
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  local _ai_wrapper="$_sb_vault/tools/ai"
  local subcmd="${1:-}"
  if [[ "$subcmd" == "end" || "$subcmd" == "distill" ]]; then
    ai-session "$@"
  elif [[ -x "$_ai_wrapper" ]]; then
    "$_ai_wrapper" "$@"
  else
    printf 'Error: no se encontró %s
' "$_ai_wrapper" >&2
    return 1
  fi
}
# --- /AI Flow shortcuts ---

