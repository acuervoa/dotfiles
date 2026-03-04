# Core Dev UX Consistency Design

Date: 2026-03-04
Scope: shell (bash), kitty, tmux, neovim
Goal: consistent UX across core dev tooling

## Objectives
- Unify typography and color palette across shell, kitty, tmux, and neovim.
- Align navigation and copy/paste behaviors to reduce context switching.
- Keep changes low risk and reversible.

## Current Baseline
- bashrc already sets editor defaults, history, completions, and tool init.
- kitty has Catppuccin-like palette, custom keymaps, and low-latency tweaks.
- tmux uses prefix `C-s`, vim-style navigation, and custom status styling.
- neovim uses cached swap/undo, leader keys, and lazy config loading.

## Proposed Approach (Recommended: Alignment Minimal)
1) Typography
   - Use the same font family and size in kitty, tmux status, and neovim UI.
2) Color palette
   - Keep a single palette (current Catppuccin-like colors) and ensure tmux status
     and neovim theme match kitty.
3) Keybinding consistency
   - Preserve: kitty uses Alt mappings, tmux uses `C-s`, nvim uses `Space`.
   - Ensure pane/window navigation uses h/j/k/l everywhere.
4) Visual indicators
   - Align status indicators (session, path, git) with a consistent style.

## Alternatives Considered
1) Theme-first
   - Full theme system, more changes and risk; higher effort.
2) Keymap-first
   - Deeper keymap changes, potential conflicts; higher cognitive adjustment.

## Risks and Mitigations
- Risk: visual changes affect habits.
  - Mitigation: keep palette and sizes close to current settings.
- Risk: keybinding collisions.
  - Mitigation: preserve current prefixes and only unify navigation patterns.

## Validation
- kitty, tmux, nvim share the same font and base palette.
- Navigation and copy/paste behaviors feel consistent.
- No regressions in tmux/nvim keymaps.
