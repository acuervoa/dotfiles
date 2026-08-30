# Diseño: gramática muscular de teclas para tmux

Fecha: 2026-08-30  
Estado: diseño aprobado para revisión escrita

## Objetivo

Convertir tmux en una interfaz operativa predecible para desarrollo backend,
servidores, automatización y agentes AI. La ruta principal de cada acción
frecuente debe ser `C-s` seguido de una sola tecla.

## Principios

- Mantener `C-s` como prefijo principal.
- Una tecla después del prefijo representa una acción completa.
- Priorizar teclas cómodas en un teclado español, evitando `AltGr` en acciones frecuentes.
- Reservar `h/j/k/l` para navegación y `H/J/K/L` para redimensionado.
- Usar menús y fzf como capa de descubrimiento para acciones poco frecuentes.
- Mantener confirmación para operaciones destructivas.
- Tratar las sesiones/proyectos como contextos recuperables, no como colecciones anónimas de panes.
- Dar a los agentes AI un espacio de control propio, sin mezclarlo con la navegación básica.

## Mapa base

### Navegación y panes

| Tecla | Acción |
|---|---|
| `h/j/k/l` | Mover foco izquierda/abajo/arriba/derecha |
| `H/J/K/L` | Redimensionar en la dirección correspondiente |
| `d` | Crear split hacia abajo |
| `r` | Crear split hacia la derecha |
| `z` | Alternar zoom del pane |
| `q` | Cerrar pane, con confirmación si procede |
| `p` | Mostrar números de panes para selección rápida |
| `!` | Convertir el pane en una ventana |

### Ventanas

| Tecla | Acción |
|---|---|
| `c` | Crear ventana en el directorio actual |
| `n/N` | Ventana siguiente/anterior |
| `a` | Volver a la última ventana |
| `,` | Renombrar ventana |
| `</>` | Mover ventana |

### Sesiones y proyectos

| Tecla | Acción |
|---|---|
| `s` | Selector de sesiones |
| `S` | Selector de proyectos |
| `$` | Renombrar sesión |
| `U` | Restaurar sesión (resurrect/restore) |

### Herramientas

| Tecla | Acción |
|---|---|
| `g` | Abrir lazygit |
| `b` | Abrir btop |
| `x` | Abrir extrakto |
| `A` | Abrir el centro de control de agentes AI |
| `m` | Abrir menú general |

### Sistema

| Tecla | Acción |
|---|---|
| `R` | Recargar configuración |

## Compatibilidad y transición

La configuración actual se conserva en el backup fechado antes de cualquier
cambio. Durante una fase de transición se podrán conservar aliases antiguos,
pero la cheatsheet y el entrenamiento solo recomendarán el mapa nuevo. Tras
validar el uso real, se eliminarán duplicados que compitan por la misma acción.

La navegación sin prefijo `C-h/j/k/l` se conservará mientras sea necesaria para
la integración con Vim/Neovim, pero no se considerará parte del núcleo tmux.

## Habitaciones futuras

La gramática será independiente de la topología concreta. En una fase posterior,
cada proyecto podrá abrir ventanas con roles estables, por ejemplo editor,
servidor, tests, logs, Git y agentes. La tecla `A` será el punto de entrada común
para lanzar, localizar, inspeccionar y detener agentes.

## Verificación antes de activar

- Validar sintaxis con la configuración candidata en una instancia aislada de tmux.
- Comprobar cada binding en teclado español real.
- Verificar que no se rompen Vim/Neovim, i3, copy-mode ni el portapapeles.
- Probar sesiones nuevas, cambio de proyecto, resurrect y reload.
- Actualizar la cheatsheet para que no documente bindings inexistentes.
- Mantener una ruta de rollback al backup fechado.

## Fuera de alcance de este diseño

- Cambiar shell, prompt, Neovim o i3.
- Añadir plugins sin una necesidad validada.
- Automatizar todavía las habitaciones de proyecto.
- Definir comandos concretos de cada agente AI antes de observar los flujos reales.
