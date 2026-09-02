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
| Historial de clipboard | clipmenu | escritorio | i3 `$mod+v` |
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
3. `clipmenu` es la autoridad histórica elegida para el clipboard visual.
   CopyQ está instalado y configurado, pero su autostart fue desactivado
   explícitamente en un commit anterior; no debe reintroducirse sin una nueva
   decisión. `pbcopy`, tmux y Neovim son transportes.
4. Polybar, tmux y Starship pueden mostrar estado Git en ámbitos distintos.
   No se retira información sin medir coste y utilidad.
5. Kitty y tmux tienen responsabilidades separadas: Kitty transporta la
   terminal y tmux conserva panes, ventanas y sesiones.
6. ble.sh está cargado en Bash con `--noattach` y se adjunta después de
   Atuin/FZF/keymap; su personalización debe respetar ese orden.
7. Rofi ya es el selector visual efectivo de i3 para aplicaciones, ventanas,
   clipboard y confirmaciones. Sus teclas comunes son flechas, `C-j/C-k`,
   `Enter` y `Escape`; Albert queda como launcher secundario pendiente de
   decisión, no como owner alternativo en los flujos de i3.
8. El transporte queda separado del estado: Kitty lleva entrada y clipboard,
   tmux conserva panes, ventanas y sesiones, i3 conserva workspaces, Polybar
   muestra estado persistente y Dunst entrega feedback no modal con foco de
   teclado e historial acotado. El contrato está cubierto por
   `tests/terminal_feedback_contract_test.sh`.

## Contrato de transporte y feedback

La configuración actual ya satisface el objetivo de coordinación, por lo que
este bloque no introduce nuevos atajos ni cambia i3, tmux o Kitty. Los límites
que se preservan son:

- `C-s` es el prefijo de tmux; `C-h/j/k/l` navega entre panes o se reenvía a
  Neovim cuando corresponde.
- Kitty sólo intercepta copiar, pegar, crear ventana/tab y secuencias Alt de
  navegación; no captura la familia de navegación de tmux.
- i3 mantiene el cambio de workspace y su modo resize bajo `$mod`.
- Polybar es el resumen persistente del escritorio; Dunst es el feedback
  efímero y consultable, con `$mod+y` para recuperar historial.

La duplicación de estado Git entre prompt, tmux y Neovim queda aceptada por
ahora: cada vista pertenece a un contexto distinto y no se ha medido un coste
que justifique retirarla.

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
