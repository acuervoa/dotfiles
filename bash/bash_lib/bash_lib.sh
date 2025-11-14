# ~/.bash_lib/bash_lib.sh
for f in core nav docker git misc; do
  # shellcheck source=/dev/null
  [ -f "$HOME/.bash_lib/${f}.sh" ] &&
    source "$HOME/.bash_lib/${f}.sh"
done
