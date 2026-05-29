#
# ~/.bash_profile
#

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

case $- in
    *i* ) [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/acuervo/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/acuervo/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac
# Tab completion for juliaup and julia channel selection
[ -f "/home/acuervo/.julia/juliaup/completions/bash.sh" ] && source "/home/acuervo/.julia/juliaup/completions/bash.sh"

# <<< juliaup initialize <<<
