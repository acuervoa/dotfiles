# Auditoría inicial de integración de aplicativos — 2026-09-02

## Alcance

Este baseline sólo inspecciona archivos versionados del repositorio y la
disponibilidad de binarios. No lee `~/.bashrc_local`, el historial privado de
Bash/Atuin ni configuraciones fuera del checkout salvo las rutas públicas de
binarios y el estado runtime necesario para comprobar disponibilidad.

Fuente reproducible:

```bash
bash scripts/audit-application-ownership.sh
```

## Owners canónicos

| Capacidad | Owner | Ámbito | Entrada principal |
|---|---|---|---|
| Launcher de aplicaciones | Rofi | selección visual | i3 `$mod+d` |
| Historial | Atuin | comandos Bash | Bash `C-r` |
| Historial de clipboard | CopyQ | escritorio | CopyQ/clipmenu |
| Prompt | Starship | Bash | prompt actual |
| Panes | tmux | terminal | `C-s` |
| Ventanas | i3 | escritorio | `$mod` |
| Editor | Neovim | código | `n`/`vim`/`EDITOR` |
| Git visual | LazyGit | proyecto | Bash `lg`, tmux `C-s g`, Neovim `<leader>gg` |
| Notificaciones | Dunst | feedback no modal | eventos de escritorio |

Owners de soporte:

| Necesidad | Aplicativo | Regla |
|---|---|---|
| Transporte terminal | Kitty | No añade un tercer sistema de sesiones |
| Edición de línea | ble.sh | No gestiona panes ni sustituye Atuin |
| Selección textual | FZF | Motor reutilizable para historial, archivos y ramas |
| Navegación de directorios | zoxide/FZF | zoxide para destinos conocidos, FZF para selección |
| Entorno de proyecto | direnv/mise/fnm | Activación por proyecto, sin bindings globales nuevos |
| Filesystem desde shell | Yazi | Separado de Telescope/Neo-tree dentro de Neovim |
| Logs | lnav | Observabilidad de Docker y servidores |
| Monitorización | btop | Estado interactivo bajo demanda |
| Estado persistente | Polybar | Workspaces, sistema y estado resumido |

## Hallazgos iniciales

1. La matriz crítica tiene un único owner por capacidad y se comprueba con
   `tests/application_ownership_test.sh`.
2. Albert y Rofi pueden solaparse como launchers. Albert queda documentado
   como launcher secundario pendiente de una auditoría de uso; no se desactiva
   automáticamente.
3. CopyQ y clipmenu pueden solaparse como interfaces de historial visual,
   mientras que `pbcopy`, tmux y Neovim son transportes. La distinción debe
   conservarse hasta completar la auditoría de clipboard.
4. Polybar, tmux y Starship pueden mostrar estado Git en ámbitos distintos.
   No se retira información sin medir coste y utilidad.
5. Kitty y tmux tienen responsabilidades separadas: Kitty transporta la
   terminal y tmux conserva panes, ventanas y sesiones.
6. ble.sh está cargado en Bash con `--noattach` y se adjunta después de
   Atuin/FZF/keymap; su personalización debe respetar ese orden.

## Dependencias opcionales

- `javac` no es necesario para los workflows actuales de PHP, Bash, Go,
  Python y Rust.
- `jsregexp` de LuaSnip sólo es necesario para transformaciones avanzadas de
  snippets.
- `wl-copy`, `xclip`, `xsel` y equivalentes son backends de transporte de
  clipboard, no owners de historial.
- Rofi, Albert, CopyQ, Dunst y Polybar son componentes gráficos; los tests
  deben poder ejecutarse sin sobrescribir clipboard ni cerrar ventanas.

## Archivos protegidos

Durante esta auditoría no se modifican:

- `~/.bashrc_local`.
- `stow/tmux/.tmux.conf`.
- `stow/i3/.config/i3/config`.

El objetivo es establecer el baseline antes de cambiar cualquier integración.
