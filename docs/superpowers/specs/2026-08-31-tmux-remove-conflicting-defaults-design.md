# Diseño: eliminar conflictos de aliases legacy en tmux

Fecha: 2026-08-31  
Estado: aprobado para revisión escrita

## Objetivo

Reducir rutas duplicadas en la gramática principal de tmux eliminando cuatro
bindings por prefijo que compiten directamente con acciones nuevas:

| Binding legacy | Ruta canónica |
|---|---|
| `C-s "` | `C-s d` para split abajo |
| `C-s %` | `C-s r` para split derecha |
| `C-s Space` | `C-s p` para mostrar panes |
| `C-s Z` | `C-s z` para alternar zoom |

El objetivo es reforzar la memoria muscular sin ampliar funcionalidad ni
modificar acciones secundarias que no compiten directamente con el núcleo.

## Alcance

Se modificará `stow/tmux/.tmux.conf` para ejecutar `unbind` explícitos sobre
las cuatro teclas legacy. Se conservarán `w`, `D`, `(`, `)`, `Tab`, `o` y el
resto de utilidades secundarias de tmux.

Se actualizarán `tmux-cheatsheet.md`, `keymap-maestro.md` y cualquier sección
de documentación que todavía presente esas cuatro rutas como disponibles.
La documentación seguirá distinguiendo entre mapa principal y atajos
secundarios conservados.

## Verificación

1. Arrancar un servidor tmux aislado con la configuración stow.
2. Confirmar que `d`, `r`, `p` y `z` mantienen sus acciones canónicas.
3. Confirmar que `"`, `%`, `Space` y `Z` no aparecen vinculadas en la tabla
   `prefix` del servidor aislado.
4. Confirmar que los bindings secundarios conservados siguen presentes.
5. Recargar la sesión activa solo después de superar la verificación aislada.

## Fuera de alcance

- Eliminar defaults secundarios sin conflicto directo.
- Cambiar el prefijo `C-s`.
- Añadir funcionalidades para agentes AI.
- Optimizar todavía los forks de la statusline.
- Modificar clipboard, Resurrect o Continuum.
