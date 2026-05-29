# tmux cheatsheet

> Prefix: `C-s`

---

## Panes

| Key | Acción |
|---|---|
| `"` | Split vertical (mismo dir) |
| `%` | Split horizontal (mismo dir) |
| `h/j/k/l` | Navegar pane |
| `Tab` / `BTab` | Pane siguiente / anterior |
| `o` | Pane siguiente |
| `;` | Alterna últimos 2 panes |
| `p` | Overlay numerado de panes |
| `{` / `}` | Swap pane arriba/abajo |
| `q` | Kill pane |
| `BSpace` | Kill todos los demás panes |
| `z` / `Z` | Zoom pane |
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
| `n` / `p` | Siguiente / anterior |
| `<` / `>` | Mover ventana izq/dcha |
| `,` | Rename ventana |
| `L` / `Space` | Siguiente layout |
| `E` | Layout horizontal parejo |
| `V` | Layout vertical parejo |

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
| `H` | btop |
| `C-p` | fzf → panes |
| `C-w` | fzf → ventanas |
| `C-b` | fzf → buffers clipboard |
| `m` | tmux-menus |
| `K` | Esta cheatsheet |

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

| Key | Acción |
|---|---|
| `M-s` | Resurrect save |
| `M-r` | Resurrect restore |
| `Y` | Copia ruta actual → clipboard |
| `T` | Toggle mouse |
| `B` | Toggle statusbar |
| `r` | Reload config |
| `f` | Find window (prompt) |
