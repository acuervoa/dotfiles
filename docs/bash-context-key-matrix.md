# Matriz de ownership de teclas entre contextos

Este documento describe la propiedad prevista de las teclas en cada capa de
interacción. La misma letra puede reaparecer porque cambia el contexto o el
modificador; por tanto, las repeticiones no son colisiones silenciosas.

## Tabla de referencia

| Capa/contexto | Teclas | Acción o ownership | Modificador/contexto que la distingue |
| --- | --- | --- | --- |
| Bash | `l`, `n`, `p`, `r`, `y`, `z` | Comandos Bash públicos de una letra | Línea de comandos, sin prefijo |
| Readline/ble.sh | `C-r` | Historial interactivo | Control |
| Readline/ble.sh | `C-t` | Selector de archivos | Control |
| Readline | `Esc-C` (`\e\C-c`) | Selector de directorios | Meta en Readline |
| ble.sh | `M-c` | Selector de directorios | Meta en ble.sh |
| Readline/ble.sh | `Tab` | `menu-complete` | Tecla de tabulación |
| Readline/ble.sh | `Shift-Tab` | No se presenta como funcional habitual; el keymap actual configura `\e[Z]` (con `]` extra) | Binding literal actual de tabulación inversa |
| Readline/ble.sh | `C-s` | Libre; Bash no lo enlaza | Control |
| tmux | `p`, `r`, `n`, `q`, `z` | Atajos de panes/ventanas y sesión | Después del prefijo `C-s` |
| tmux | `y` | Copiar en `copy-mode-vi` | Contexto `copy-mode-vi`, sin prefijo |
| i3 | `Mod4+r` | Entrar en modo resize | Modificador `Mod4` |
| i3 | `Mod4+q` | Cerrar la ventana enfocada (con confirmación) | Modificador `Mod4` |
| i3 | `Mod4+y` | Historial de Dunst | Modificador `Mod4` |
| i3 | `Mod4+z` | Alternar fullscreen | Modificador `Mod4` |
| i3 | `Mod4+Shift+n` | Alternar scratchpad de Obsidian | Modificadores `Mod4+Shift` |

## Bash

Los comandos Bash de una letra reservados en esta matriz son exactamente
`l`, `n`, `p`, `r`, `y` y `z`. Son nombres de comando en la línea de comandos;
no representan bindings de Readline ni teclas de tmux o i3.

## Readline/ble.sh

La capa de edición interactiva conserva `C-r` y `C-t`. En Readline, el
selector de directorios está en `Esc-C` (`\e\C-c`); en ble.sh, el equivalente
es `M-c`. `Tab` completa hacia delante mediante `menu-complete`.

`Shift-Tab` no se presenta como funcional habitual: el keymap actual configura
literalmente `\e[Z]`, con un corchete `]` extra al final. La verificación debe
reflejar exactamente ese binding actual, sin documentarlo como si fuera un
`Shift-Tab` funcional. `C-s` permanece libre: Bash no lo enlaza, para que pueda
actuar como prefijo de tmux cuando corresponda.

## tmux

El prefijo de tmux definido por la configuración base es `C-s`. El archivo
`~/.tmux.conf.local` puede sobrescribirlo; por eso los checks deben consultar
el valor efectivo. Después de ese prefijo, las teclas reservadas son `p`, `r`,
`n`, `q` y `z`. La tecla `y` pertenece a la tabla `copy-mode-vi`, donde copia
la selección; no es un atajo de la tabla de prefijo.

## i3

La capa del gestor de ventanas usa `Mod4` como modificador. Sus bindings de
esta matriz son `Mod4+r`, `Mod4+q`, `Mod4+y`, `Mod4+z` y
`Mod4+Shift+n`, cada uno independiente de los comandos escritos en Bash y de
las teclas posteriores al prefijo de tmux.

## Por qué no hay colisiones silenciosas

Una letra repetida cambia de significado al cambiar de capa o modificador:

- Bash `r` es un comando escrito directamente; tmux `C-s r` requiere primero
  el prefijo; i3 `Mod4+r` requiere el modificador del gestor de ventanas.
- Bash `p` es un comando escrito directamente; tmux `C-s p` sólo se activa
  después del prefijo.
- Del mismo modo, `n`, `y` y `z` no compiten entre Bash, tmux e i3 porque
  pertenecen a contextos distintos (`C-s`, `copy-mode-vi` o `Mod4`).

La distinción es semántica y observable: no se debe interpretar el nombre de
la letra aislada como si todos los keymaps compartieran una única tabla.

## Checks de sólo lectura

Estos comandos inspeccionan bindings efectivos; no modifican configuración ni
recargan servicios:

```bash
bind -X
bind -q menu-complete
bind -q menu-complete-backward
tmux show-options -gqv prefix
tmux list-keys -T prefix
i3-msg -t get_config
```

## Invariantes y alcance

- El prefijo de tmux definido por la configuración base es `C-s`; `~/.tmux.conf.local` puede sobrescribirlo.
- Bash no enlaza `C-s`.
- Las letras repetidas entre capas no constituyen colisiones silenciosas.
- Este documento no implica cambios de configuración, tests ni runtime.

Las fuentes de referencia son [`stow/bash/.bash_lib/keymap.sh`](../stow/bash/.bash_lib/keymap.sh),
[`stow/tmux/.tmux.conf`](../stow/tmux/.tmux.conf),
[`stow/i3/.config/i3/config`](../stow/i3/.config/i3/config) y la
[`auditoría de comandos Bash del 2026-08-31`](audits/2026-08-31-bash-command-audit.md).
