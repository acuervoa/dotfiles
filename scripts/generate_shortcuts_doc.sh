#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/SHORTCUTS.md"
TMP_DIR="$(mktemp -d)"

# Ensure cleanup on exit
trap 'rm -rf "$TMP_DIR"' EXIT

# --- Helper Functions ---
info() { printf "\e[34m[INFO]\e[0m %s\n" "$*"; }
warn() { printf "\e[33m[WARN]\e[0m %s\n" "$*"; }
error() { printf "\e[31m[ERROR]\e[0m %s\n" "$*" >&2; exit 1; }

# --- Parsing Functions ---

parse_i3_config() {
    local config_file="$REPO_ROOT/stow/i3/.config/i3/config"
    info "Parsing i3 config: $config_file"
    # Example: extract bindsym
    # Expected output format: | Atajo / Shortcut | Acción |
    
    # This is a placeholder. Actual parsing will be more complex.
    echo "#### i3 ("stow/i3/.config/i3/config")"
    echo ""
    echo "| Atajo / Shortcut | Acción |
| ---------------- | ------ |"
    grep -E 'bindsym|bindcode' "$config_file" | grep -vE '^\s*#' | while read -r line; do
        # Simplified extraction for now
        local shortcut=$(echo "$line" | awk '{print $2}')
        local action=$(echo "$line" | cut -d' ' -f3- | sed 's/^--\s*//') # Remove leading comment if any
        # Further processing needed to clean up action and handle variables like $mod
        echo "| $shortcut | $action |"
    done
    echo ""
}

parse_tmux_config() {
    local config_file="$REPO_ROOT/stow/tmux/.tmux.conf"
    info "Parsing tmux config: $config_file"
    echo "#### tmux ("stow/tmux/.tmux.conf")"
    echo ""
    echo "| Atajo / Shortcut | Descripción / Action |
| ---------------- | -------------------- |
"
    grep -E 'bind-key|bind -n' "$config_file" | grep -vE '^\s*#' | while read -r line; do
        # Simplified extraction
        local shortcut=$(echo "$line" | awk '{print $2, $3}')
        local action=$(echo "$line" | cut -d' ' -f4- | sed 's/^--\s*//')
        echo "| $shortcut | $action |"
    done
    echo ""
}

parse_kitty_config() {
    local config_file="$REPO_ROOT/stow/kitty/.config/kitty/kitty.conf"
    info "Parsing kitty config: $config_file"
    echo "#### Kitty ("stow/kitty/.config/kitty/kitty.conf")"
    echo ""
    echo "| Atajo / Shortcut | Acción |
| ---------------- | ------ |
"
    grep -E 'map' "$config_file" | grep -vE '^\s*#' | while read -r line; do
        local shortcut=$(echo "$line" | awk '{print $2, $3}')
        local action=$(echo "$line" | cut -d' ' -f4- | sed 's/^--\s*//')
        echo "| $shortcut | $action |"
    done
    echo ""
}

parse_nvim_keymaps() {
    local config_file="$REPO_ROOT/stow/nvim/.config/nvim/lua/config/keymaps.lua"
    info "Parsing NeoVim keymaps: $config_file"
    echo "#### NeoVim ("stow/nvim/.config/nvim/lua/config/keymaps.lua")"
    echo ""
    echo "| Atajo / Shortcut | Modo | Acción |
| ---------------- | ---- | ------ |
"
    # This will be much harder to parse accurately without a Lua parser.
    # Placeholder: Look for vim.keymap.set calls
    grep -E 'vim.keymap.set' "$config_file" | grep -vE '^\s*--' | while read -r line; do
        # Simplified: extract mode, lhs, rhs, desc
        # Pattern: vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        local mode=$(echo "$line" | grep -oP 'vim.keymap.set\(\s*("|\x27)(.*?)\x27' | sed -E 's/vim.keymap.set\(("|\x27)(.*?)\x27/\2/g')
        local lhs=$(echo "$line" | grep -oP '\x27(.*?)\x27\s*,\s*\x27(.*?)\x27' | sed -E 's/\x27(.*?)\x27\s*,\s*\x27(.*?)\x27/\1/g')
        local rhs=$(echo "$line" | grep -oP ',\s*\x27(.*?)\x27\s*,\s*{' | sed -E 's/,\s*\x27(.*?)\x27\s*,\s*{/\1/g')
        local desc=$(echo "$line" | grep -oP 'desc\s*=\s*\x27(.*?)\x27' | sed -E 's/desc\s*=\s*\x27(.*?)\x27/\1/g')

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
    cat <<EOF > "$OUTPUT_FILE"
# SHORTCUTS · Paridad i3 ↔ tmux ↔ (Neo)Vim ↔ kitty ↔ polybar (+ CLI helpers)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Atajos por entorno / Shortcuts by environment

EOF
    
    parse_i3_config >> "$OUTPUT_FILE"
    parse_tmux_config >> "$OUTPUT_FILE"
    parse_kitty_config >> "$OUTPUT_FILE"
    parse_nvim_keymaps >> "$OUTPUT_FILE"
    # Add other sections later

    info "SHORTCUTS.md generated successfully at $OUTPUT_FILE"
}

main
