# ~/.bash_lib/keymap.sh
# Owner único de los bindings interactivos de Bash.

# shellcheck shell=bash

_bash_keymap_history() {
  if declare -F __atuin_history >/dev/null 2>&1; then
    __atuin_history
  elif declare -F fhist >/dev/null 2>&1; then
    fhist
  else
    printf 'Historial interactivo no disponible.\n' >&2
    return 1
  fi
}

_bash_keymap_files() {
  if declare -F fo >/dev/null 2>&1; then
    fo
  else
    printf 'Selector de archivos no disponible.\n' >&2
    return 1
  fi
}

_bash_keymap_dirs() {
  if declare -F cdf >/dev/null 2>&1; then
    cdf
  else
    printf 'Selector de directorios no disponible.\n' >&2
    return 1
  fi
}

if type -t bind >/dev/null 2>&1; then
  if declare -F __atuin_history >/dev/null 2>&1; then
    bind -x '"\C-r":__atuin_history'
  else
    bind -x '"\C-r":_bash_keymap_history'
  fi

  bind -x '"\C-t":_bash_keymap_files'
  bind -x '"\e\C-c":_bash_keymap_dirs'
  bind 'set completion-ignore-case on'
  bind 'set show-all-if-ambiguous on'
  bind 'set menu-complete-display-prefix on'
  bind '"\t": menu-complete'
  bind '"\e[Z]": menu-complete-backward'
fi

if [[ ${BLE_VERSION-} ]] && declare -F ble-bind >/dev/null 2>&1; then
  if declare -F __atuin_history >/dev/null 2>&1; then
    ble-bind -x 'C-r' __atuin_history
  else
    ble-bind -x 'C-r' _bash_keymap_history
  fi
  ble-bind -x 'C-t' _bash_keymap_files
  ble-bind -x 'M-c' _bash_keymap_dirs
fi
