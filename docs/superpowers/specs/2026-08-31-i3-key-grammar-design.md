# Diseño: gramática muscular de teclas para i3

Fecha: 2026-08-31  
Estado: diseño propuesto para revisión

## Objetivo

Hacer que i3 comparta la lógica espacial de tmux sin tocar el prefijo ni los
bindings de tmux. Las acciones frecuentes de i3 usarán `Super` y la familia
`h/j/k/l`, mientras que tmux seguirá usando `C-s`.

## Mapa propuesto

| Tecla | Acción |
|---|---|
| `Super+h/j/k/l` | Foco izquierda/abajo/arriba/derecha |
| `Super+Shift+h/j/k/l` | Mover contenedor izquierda/abajo/arriba/derecha |
| `Super+r` | Entrar en modo resize |
| `h/j/k/l` en modo resize | Redimensionar 10 px en la dirección correspondiente |
| `q`, `Escape` o `Return` en modo resize | Volver al modo normal |

Los bindings con flechas para foco, movimiento y resize se retirarán del mapa
principal para evitar rutas duplicadas. Los workspaces, layouts, scratchpads,
launchers y el arranque automático de tmux no cambiarán.

## Separación con tmux

La separación de scopes permanece explícita:

- i3 gestiona ventanas, contenedores, workspaces y monitores con `Super`.
- tmux gestiona panes, ventanas, sesiones y plugins con `C-s`.
- No se modificarán `C-h/j/k/l`, `C-s` ni ningún binding de la tabla `prefix`.

## Verificación

1. Validar sintaxis de i3 en modo comprobación.
2. Comprobar que los bindings `Super+h/j/k/l`, `Super+Shift+h/j/k/l` y
   `Super+r` aparecen en la configuración efectiva.
3. Comprobar que el modo `resize` contiene `h/j/k/l`, `q`, `Escape` y `Return`.
4. Recargar i3 y comprobar que tmux conserva `C-s`, navegación, splits y zoom.
5. Mantener el backup i3 anterior como rollback.

## Fuera de alcance

- Cambiar el prefijo o la gramática de tmux.
- Rediseñar workspaces numéricos.
- Añadir funciones para agentes AI.
- Cambiar scratchpads, Polybar, Picom o la política de monitores.
