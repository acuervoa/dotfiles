# ~/.profile  - entorno general para shells de login (POSIX)

export PATH="$HOME/.local/bin:$PATH"

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
