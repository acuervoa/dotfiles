#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/SHORTCUTS.md"
TMP_DIR="$(mktemp -d)"

# Ensure cleanup on exit
trap 'rm -rf "$TMP_DIR"' EXIT

# --- Helper Functions ---
info() { printf "\e[34m[INFO]\e[0m %s\n" "$*" >&2; }
warn() { printf "\e[33m[WARN]\e[0m %s\n" "$*" >&2; }
error() {
  printf "\e[31m[ERROR]\e[0m %s\n" "$*" >&2
  exit 1
}

# --- Parsing Functions ---

parse_i3_config() {
  local config_file="$REPO_ROOT/stow/i3/.config/i3/config"
  info "Parsing i3 config: $config_file"
  # Example: extract bindsym
  # Expected output format: | Atajo / Shortcut | Acción |

  # This is a placeholder. Actual parsing will be more complex.
  echo "#### i3 (stow/i3/.config/i3/config)"
  echo ""
  printf '%s\n' "| Atajo / Shortcut | Acción |" "| ---------------- | ------ |"

  { grep -E 'bindsym|bindcode' "$config_file" || true; } |
    { grep -vE '^\s*#' || true; } |
    while read -r line; do
      # Simplified extraction for now
      local shortcut
      local action
      shortcut="$(echo "$line" | awk '{print $2}')"
      action="$(echo "$line" | cut -d' ' -f3- | sed 's/^--\s*//')" # Remove leading comment if any

      # Further processing needed to clean up action and handle variables like $mod
      echo "| $shortcut | $action |"
    done
  echo ""

}

parse_tmux_config() {
  local config_file="$REPO_ROOT/stow/tmux/.tmux.conf"
  info "Parsing tmux config: $config_file"
  echo "#### tmux (stow/tmux/.tmux.conf)"
  echo ""
  printf '%s\n' "| Atajo / Shortcut | Descripción / Action |" "| ---------------- | -------------------- |"

  cat <<'EOF'
| `C-s h/j/k/l` | Mover foco entre panes |
| `C-s H/J/K/L` | Redimensionar pane |
| `C-s d/r` | Split abajo / derecha |
| `C-s z` | Alternar zoom del pane |
| `C-s p` | Mostrar números de panes |
| `C-s q` | Cerrar pane con confirmación |
| `C-s c` | Nueva ventana |
| `C-s n/N` | Ventana siguiente / anterior |
| `C-s a` | Última ventana |
| `C-s ,` | Renombrar ventana |
| `C-s </>` | Mover ventana |
| `C-s s/S` | Selector de sesiones / proyectos |
| `C-s $` | Renombrar sesión |
| `C-s g/b` | Popups de lazygit / btop |
| `C-s x` | Extrakto |
| `C-s C-p/C-w/C-b` | fzf: panes / ventanas / buffers |
| `C-s m` | Menú tmux-menus |
| `C-s u/U` | Resurrect: guardar / restaurar |
| `C-s R` | Recargar configuración |
| `C-s ?` | Abrir cheatsheet |
EOF

  echo "Atajos secundarios o de compatibilidad:"
  echo ""

  { grep -E 'bind-key|bind -n' "$config_file" || true; } |
    { grep -vE '^\s*#' || true; } |
    while read -r line; do
      # Simplified extraction
      local shortcut
      local action
      shortcut="$(echo "$line" | awk '{print $2, $3}')"
      action="$(echo "$line" | cut -d' ' -f4- | sed 's/^--\s*//')"
      echo "| $shortcut | $action |"
    done
  echo ""

}

parse_kitty_config() {
  local config_file="$REPO_ROOT/stow/kitty/.config/kitty/kitty.conf"
  info "Parsing kitty config: $config_file"
  echo "#### Kitty (stow/kitty/.config/kitty/kitty.conf)"
  echo ""
  printf '%s\n' "| Atajo / Shortcut | Acción |" "| ---------------- | ------ |"

  { grep -E 'map' "$config_file" || true; } |
    { grep -vE '^\s*#' || true; } |
    while read -r line; do
      local shortcut
      local action
      shortcut="$(echo "$line" | awk '{print $2, $3}')"
      action="$(echo "$line" | cut -d' ' -f4- | sed 's/^--\s*//')"
      echo "| $shortcut | $action |"
    done
  echo ""

}

parse_nvim_keymaps() {
  local config_file="$REPO_ROOT/stow/nvim/.config/nvim/lua/config/keymaps.lua"
  info "Parsing NeoVim keymaps: $config_file"
  echo "#### NeoVim (stow/nvim/.config/nvim/lua/config/keymaps.lua)"
  echo ""
  printf '%s\n' "| Atajo / Shortcut | Modo | Acción |" "| ---------------- | ---- | ------ |"

  # This will be much harder to parse accurately without a Lua parser.
  # Placeholder: Look for vim.keymap.set calls
  { grep -E 'vim.keymap.set' "$config_file" || true; } |
    { grep -vE '^\s*--' || true; } |
    while read -r line; do
      # Simplified: extract mode, lhs, rhs, desc
      # Pattern: vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
      local mode
      local lhs
      local rhs
      local desc
      mode="$(echo "$line" | grep -oP 'vim.keymap.set\(\s*("|\x27)(.*?)\x27' | sed -E 's/vim.keymap.set\(("|\x27)(.*?)\x27/\2/g' || true)"
      lhs="$(echo "$line" | grep -oP '\x27(.*?)\x27\s*,\s*\x27(.*?)\x27' | sed -E 's/\x27(.*?)\x27\s*,\s*\x27(.*?)\x27/\1/g' || true)"
      rhs="$(echo "$line" | grep -oP ',\s*\x27(.*?)\x27\s*,\s*{' | sed -E 's/,\s*\x27(.*?)\x27\s*,\s*[{]/\1/g' || true)"
      desc="$(echo "$line" | grep -oP 'desc\s*=\s*\x27(.*?)\x27' | sed -E 's/desc\s*=\s*\x27(.*?)\x27/\1/g' || true)"

      if [[ -n "$mode" && -n "$lhs" && -n "$rhs" ]]; then
        echo "| $lhs | $mode | $desc |"
      fi
    done
  echo ""
}

# --- Main Script ---
main() {
  info "Generating SHORTCUTS.md..."

  # Header and TOC (can be kept static or parsed from existing SHORTCUTS.md)
  cat <<EOF >"$OUTPUT_FILE"
# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Atajos por entorno / Shortcuts by environment

EOF

  {
    parse_i3_config
    parse_tmux_config
    parse_kitty_config
    parse_nvim_keymaps

    cat <<'EOF'
## Gramática coordinada y owners

| Contexto | Owner | Regla muscular |
|----------|-------|----------------|
| i3 | i3 | `$mod` cambia workspace o lanza una aplicación |
| Kitty | Kitty | Transporte de terminal, clipboard y secuencias Alt |
| tmux | tmux | `C-s` + acción gestiona panes, ventanas y sesiones |
| Bash/ble.sh | Bash/ble.sh | Comandos y edición de línea; `C-r` consulta Atuin |
| Neovim | Neovim | `<leader>` + grupo gestiona código, tareas y revisión |
| Rofi | Rofi | Selector visual: elegir, `Enter` aceptar, `Escape` cancelar |
| clipmenu | clipmenu | Historial de clipboard; Kitty/tmux sólo transportan |
| Feedback | Polybar/Dunst | Estado persistente en Polybar, eventos en Dunst |
| Proyecto | `tproj`/`dev` | Contexto tmux; LazyGit, Yazi y lnav son herramientas de trabajo |

### Secuencias de memoria muscular

1. Proyecto: `tproj` o `dev` → tmux conserva contexto → Neovim edita.
2. Navegación: `C-h/j/k/l` mueve foco en tmux/Neovim; `$mod` cambia workspace.
3. Validación: `<leader>pt/pT`, `<leader>pf/pl` ejecutan test, formato y lint.
4. Revisión: `lg`, `C-s g` o `<leader>gg` abren LazyGit en su contexto.
5. Observabilidad: `dlogs`/`lnav` inspeccionan logs y `C-s b` abre btop.
6. Cierre: `Escape` cancela selectores; `C-s q` cierra un pane con confirmación.

Las teclas `p/r/y/n/z` conservan su semántica nativa dentro de Vim; en Bash
son comandos o wrappers (`p` para PHP, `r` para repetir, `y` para Yazi,
`n/z` según el catálogo). El contexto decide la acción: no se redefinen las
teclas de movimiento o edición del editor para imitar Bash.
EOF
  } >>"$OUTPUT_FILE"
  # Add other sections later

  info "SHORTCUTS.md generated successfully at $OUTPUT_FILE"
}

main
