# ~/.profile  - entorno general para shells de login (POSIX)

export EDITOR="nvim"
export VISUAL="nvim"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export PROJECTS_ROOT="$HOME/Workspace"
export PROFILE_LOADED="yes"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/acuervo/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/acuervo/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<


# Rutas estáticas del usuario: un único owner y orden determinista.
_bash_path_prepend_once() {
  local path="$1"
  local required="${2:-optional}"

  if [ "$required" != force ] && [ ! -d "$path" ]; then
    return 0
  fi

  case ":${PATH:-}:" in
  *:"$path":*) ;;
  *) PATH="$path${PATH:+:$PATH}" ;;
  esac
}

export BUN_INSTALL="$HOME/.bun"
_bash_path_prepend_once "$HOME/.local/share/composer/vendor/bin"
_bash_path_prepend_once "$HOME/.opencode/bin"
_bash_path_prepend_once "$BUN_INSTALL/bin"
_bash_path_prepend_once "$HOME/bin"
_bash_path_prepend_once "$HOME/.local/bin" force
export PATH

unset -f _bash_path_prepend_once 2>/dev/null || :
