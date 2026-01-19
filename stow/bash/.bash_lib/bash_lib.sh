# ~/.bash_lib/bash_lib.sh
# shellcheck shell=bash
# Punto de entrada de bash_lib

# Directorio base de módulos.
BASH_LIB_DIR="${BASH_LIB_DIR:-$HOME/.bash_lib}"

for f in core nav docker git misc; do
  # shellcheck source=/dev/null
  [ -f "$BASH_LIB_DIR/${f}.sh" ] && source "$BASH_LIB_DIR/${f}.sh"
done
