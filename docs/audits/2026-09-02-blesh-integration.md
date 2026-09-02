# Integración ble.sh — 2026-09-02

## Resultado del baseline

ble.sh ya se carga desde `/usr/share/blesh/ble.sh` con `--noattach` en
`stow/bash/.bashrc` y se adjunta una sola vez después de cargar Atuin, aliases,
funciones y `stow/bash/.bash_lib/keymap.sh`.

La configuración específica está centralizada en
`stow/blesh/.config/blesh/blerc`, con `stow/blesh/.blerc` como shim de
compatibilidad para instalaciones que buscan ese path.

## Ownership efectivo

| Acción | Owner | Binding |
|---|---|---|
| Buscar historial | Atuin, con fallback Bash/FZF | `C-r` |
| Seleccionar archivos | `_bash_keymap_files`/FZF | `C-t` |
| Seleccionar directorios | `_bash_keymap_dirs`/FZF | `M-c` |
| Syntax highlighting y completion | ble.sh | edición de línea |
| Prompt | Starship | prompt Bash |
| Panes y sesiones | tmux | `C-s` |
| Aplicaciones y ventanas | i3 | `$mod` |

La integración FZF se importa mediante ble.sh. Los scripts clásicos de
`/usr/share/fzf/key-bindings.bash` permanecen desactivados para no duplicar
`C-r`, `C-t` ni `M-c`.

## Decisiones

- No activar `set -o vi`: Neovim ya es el editor modal y Bash conserva su
  edición actual con bindings selectivos.
- No asignar `C-s`: tmux lo reserva como prefijo.
- No sustituir Starship ni Atuin.
- Mantener `complete_auto_delay=120` y los indicadores de error/ejecución
  mínimos definidos en `blerc`.
- No añadir widgets globales hasta observar una fricción repetida.

## Validación

```bash
bash tests/blesh_integration_test.sh
```

El test crea una HOME y un TTY temporales, no lee `~/.bashrc_local`, no usa el
historial privado y no modifica el clipboard del usuario.
