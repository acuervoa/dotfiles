---
type: resource
summary: '| Key | Acción |'
created: 2026-06-01
updated: 2026-06-01
status: draft
tags:
- resource
- reference
---

---
# [[TMUX|tmux]] cheatsheet

> Prefix: `C-s`

> Núcleo: `C-s` + una tecla = una acción. `h/j/k/l` mueve; `H/J/K/L` redimensiona.

---

## Panes

| Key | Acción |
|---|---|
| `h/j/k/l` | Navegar pane |
| `H/J/K/L` | Redimensionar pane |
| `d` / `r` | Split abajo / derecha |
| `Tab` / `BTab` | Pane siguiente / anterior |
| `o` | Pane siguiente |
| `;` | Alterna últimos 2 panes |
| `p` | Overlay numerado de panes |
| `{` / `}` | Swap pane arriba/abajo |
| `q` | Kill pane (confirmación) |
| `BSpace` | Kill todos los demás panes (confirmación) |
| `z` | Zoom pane |
| `!` | Break pane → ventana nueva |
| `+` | Join pane (prompt) |
| `\|` | Join pane horizontal (prompt) |
| `_` | Join pane vertical (prompt) |

**Sin prefix** (smart — pasa a vim si está activo):

| Key | Acción |
|---|---|
| `C-h/j/k/l` | Navegar pane |
| `M-S-←/→/↑/↓` | Resize pane |
| `F10` | Toggle sync panes |

---

## Ventanas

| Key | Acción |
|---|---|
| `c` | Nueva ventana (mismo dir) |
| `a` | Última ventana |
| `n` / `N` | Siguiente / anterior |
| `<` / `>` | Mover ventana izq/dcha |
| `,` | Rename ventana |
| `E` / `V` | Layout horizontal / vertical |

**Sin prefix:**

| Key | Acción |
|---|---|
| `M-←/→` | Ventana anterior/siguiente |
| `C-PageUp/Down` | Ventana anterior/siguiente |

---

## Sesiones

| Key | Acción |
|---|---|
| `s` | choose-tree |
| `S` | SessionX (o choose-tree) |
| `$` | Rename sesión |
| `C-n` | Nueva sesión (prompt) |
| `t` | Pick proyecto (script) |
| `C-t` | Nueva sesión proyecto |
| `A` | Attach sesión proyecto |

---

## Popups

| Key | Acción |
|---|---|
| `g` | lazygit |
| `b` | btop |
| `C-p` | fzf → panes |
| `C-w` | fzf → ventanas |
| `C-b` | fzf → buffers clipboard |
| `m` | tmux-menus |
| `?` | Esta cheatsheet |

---

## Copy mode (vi)

| Key | Acción |
|---|---|
| `/` | Entrar copy-mode |
| `x` | Extrakto (extrae texto con fzf) |
| `v` | Begin selection |
| `V` | Select line |
| `C-v` | Rectangle selection |
| `y` / `Enter` | Copy → clipboard |
| `o` | Copy + abrir URL/archivo |
| `Escape` | Cancel |

---

## Misc

`C-s` es el prefijo. Las combinaciones con `Tab`, `o`, `BSpace`, `+`, `|`, `_`,
`M-S-flechas` y `M-flechas` son atajos secundarios o de compatibilidad; el mapa
principal para entrenar la memoria muscular es el de una tecla después del
prefijo.

| Key | Acción |
|---|---|
| `u` | Resurrect save |
| `U` | Resurrect restore |
| `Y` | Copia ruta actual → clipboard |
| `T` | Toggle mouse |
| `B` | Toggle statusbar |
| `R` | Reload config |
| `f` | Find window (prompt) |
