# Diseño: guía práctica progresiva del entorno

## Objetivo

Crear dos guías orientadas al uso diario, una en español y otra en inglés, que
permitan aprender el entorno por secuencias de trabajo. Deben reducir la carga
de recordar dónde vive cada función, sin sustituir ni alterar la configuración
existente.

## Audiencia y alcance

La audiencia es la persona usuaria del workspace, que conoce las herramientas
por separado pero necesita integrar los cambios recientes. La guía española
será la referencia principal y la inglesa mantendrá la misma estructura y
significado. El alcance cubre
Kitty, i3, tmux, Bash/ble.sh, Atuin, FZF, Rofi, clipmenu, Neovim, LazyGit,
Yazi, Docker/logs y btop.

Quedan fuera la explicación interna de cada plugin, la optimización de
arranque y cualquier cambio de bindings. Esas materias se referencian en la
documentación técnica existente.

## Estructura de las guías

Ambos documentos seguirán el mismo recorrido progresivo, traducido de forma
natural al idioma correspondiente:

1. modelo mental de ownership y contexto;
2. arranque de una sesión y navegación i3/tmux;
3. apertura y edición de un proyecto;
4. búsqueda, historial y clipboard;
5. ejecución de tests, formato, lint y tareas;
6. revisión Git;
7. logs, procesos y Docker;
8. cierre, cancelación y recuperación;
9. tres ejercicios completos y una referencia breve.

Cada capítulo tendrá: objetivo, secuencia principal, resultado esperado,
cancelación o fallback y enlaces a la referencia detallada. Los atajos se
presentarán dentro de workflows, no como listas aisladas.

## Ownership que se explicará

| Contexto | Owner | Función |
|---|---|---|
| i3 | i3 | workspaces y aplicaciones |
| Kitty | Kitty | transporte de terminal y clipboard |
| tmux | tmux | panes, ventanas y sesiones; prefijo `C-s` |
| Bash/ble.sh | Bash/ble.sh | comandos y edición de línea |
| Neovim | Neovim | código, LSP y tareas |
| Rofi | Rofi | selecciones visuales |
| clipmenu | clipmenu | historial de clipboard |
| LazyGit | LazyGit | revisión Git visual |
| Polybar/Dunst | Polybar/Dunst | estado persistente y eventos |

## Robustez y degradación

La guía indicará qué hacer si falta una dependencia opcional o si una selección
se cancela. No recomendará ejecutar operaciones mutantes durante ejercicios de
orientación. Las acciones destructivas conservarán las confirmaciones ya
existentes.

## Validación

- Todos los comandos y mappings citados deben existir en los archivos
  versionados actuales.
- Ambas guías deben enlazar `SHORTCUTS.md`, `USAGE.md`, los workflows de
  Neovim y los audits de integración.
- Un test estático comprobará las secciones, los owners y las entradas críticas.
- Se ejecutarán `bash scripts/check.sh`, el release gate y `git diff --check`.
- No se modificarán `.bashrc_local`, tmux ni i3.
