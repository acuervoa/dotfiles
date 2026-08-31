# Bash Interactive Keymap Design

## Objetivo

Crear una capa única, explícita e idempotente para los bindings interactivos de
Bash, manteniendo la precedencia de tmux y ofreciendo el mismo modelo mental en
Readline y ble.sh.

## Estado confirmado

- Atuin es el owner efectivo de `Ctrl-r` cuando está instalado.
- `fhist` es el fallback previsto para `Ctrl-r`.
- Readline tiene `Ctrl-s` asociado a búsqueda hacia delante, pero tmux usa
  `Ctrl-s` como prefijo; Bash no debe apropiarse de esa tecla.
- Tab y Shift-Tab ya usan completion por menú en Readline.
- ble.sh está instalado, pero requiere una sesión TTY real para verificar sus
  bindings.
- No hay owner Bash confirmado para `Ctrl-t` ni `Alt-c`.

## Diseño elegido

Se añadirá una capa explícita de bindings cargada después de las integraciones
de Atuin y ble.sh.

- `Ctrl-r`: Atuin si está disponible; `fhist` si no.
- `Ctrl-t`: selector de archivos con FZF.
- `Alt-c`: selector de directorios con FZF/zoxide.
- Tab y Shift-Tab: se conserva el completion por menú existente.
- `Ctrl-s`: no se modifica en Bash; queda reservado para tmux.

En ble.sh se declararán los mismos owners mediante `ble-bind` sólo cuando
`BLE_VERSION` exista. En Readline se usarán `bind` y funciones wrapper. La
capa será idempotente: recargar `.bashrc` no añadirá bindings duplicados ni
cambiará el owner efectivo.

## Compatibilidad

- No se modifican tmux, i3 ni el prefijo `Ctrl-s`.
- Atuin conserva prioridad sobre el historial alternativo.
- Las funciones existentes (`fo`, `cdf`, `fhist`) se reutilizan; no se duplican
  selectores.
- Si FZF o zoxide no están disponibles, los bindings nuevos fallan limpiamente
  y no bloquean el arranque.
- `.bashrc_local` no se toca.

## Validación

Se probarán shells sintéticas Readline con comandos falsos y dos reloads. Se
comprobará que `Ctrl-r`, `Ctrl-t` y `Alt-c` tienen un único owner, que `Ctrl-s`
no es reasignado por la configuración y que los bindings existentes permanecen
estables. La paridad ble se certificará manualmente en Kitty + tmux.

## Fuera de alcance

- Cambiar el prefijo de tmux.
- Activar `set -o vi`.
- Rediseñar completion de Bash.
- Añadir más teclas hasta medir el uso real de esta capa.
