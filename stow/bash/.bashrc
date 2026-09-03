# shellcheck shell=bash
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

# FZF + ripgrep / fd
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git"'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f'
fi

# Opciones por defecto FZF
# Colores: Catppuccin Mocha (catppuccin/fzf, accent blue).
export FZF_DEFAULT_OPTS="
    --height 50%
    --layout=reverse
    --info=inline
    --border
    --margin=1,1
    --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8
    --color=selected-bg:#45475A
    --color=border:#6C7086,label:#CDD6F4
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

# pbcopy/pbpaste: el backend se decide por el protocolo gráfico activo.
pbcopy() {
  _clipboard_command copy || return 1
  _clipboard_copy
}

pbpaste() {
  _clipboard_command paste || return 1
  "${_CLIPBOARD_CMD[@]}"
}

# -- Atuin (historial avanzado) + binding robusto de C-r ----
HIST_BACKEND="fzf" # valor por defecto si no hay Atuin
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-up-arrow)"
  # HIST_BACKEND se conserva como estado de compatibilidad; no se exporta.
  # shellcheck disable=SC2034
  HIST_BACKEND="atuin"
fi


# --- Keymap Bash: un solo owner después de Atuin ---
if [ -r "$HOME/.bash_lib/keymap.sh" ]; then
  . "$HOME/.bash_lib/keymap.sh"
fi

# --- Adjuntar ble.sh una vez que todo lo demás está configurado --
if [[ $- == *i* ]] && [[ ${BLE_VERSION-} ]]; then
  ble-attach
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

# Tab completion for juliaup and julia channel selection
[ -f "/home/acuervo/.julia/juliaup/completions/bash.sh" ] && source "/home/acuervo/.julia/juliaup/completions/bash.sh"

# Normalización final: captura overrides locales y activaciones dinámicas.
PATH="$(/usr/bin/awk -v RS=: '!seen[$0]++{out=out (NR==1? "": ":") $0} END{print out}' <<<"$PATH")"

move_to_front() {
  local p="$1"
  PATH="$(/usr/bin/tr ':' '\n' <<<"$PATH" | /usr/bin/awk -v p="$p" '$0!=p' | paste -sd: -)"
  PATH="$p${PATH:+:$PATH}"
}
move_to_front "$HOME/.local/share/composer/vendor/bin"
move_to_front "$HOME/.opencode/bin"
move_to_front "$HOME/.bun/bin"
move_to_front "$HOME/bin"
move_to_front "$HOME/.local/bin"

move_to_end() {
  local p="$1"
  PATH="$(/usr/bin/tr ':' '\n' <<<"$PATH" | /usr/bin/awk -v p="$p" '$0!=p{a[++n]=$0; next} {b[++m]=$0} END{for(i=1;i<=n;i++)print a[i]; for(j=1;j<=m;j++)print b[j]}' | paste -sd: -)"
}
move_to_end "$HOME/.nix-profile/bin"
move_to_end "/nix/var/nix/profiles/default/bin"
unset -f move_to_end 2>/dev/null || true
unset -f move_to_front 2>/dev/null || true
export PATH
