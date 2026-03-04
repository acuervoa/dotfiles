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
