# Stack Status

Date: 2026-03-05

## Core Dev
- **Shell**: bash
- **Terminal**: kitty
- **Multiplexer**: tmux (prefix `C-s`)
- **Editor**: Neovim
- **Prompt**: starship

## WM/UX (Primary)
- **WM**: i3
- **Compositor**: picom
- **Bar**: polybar
- **Launcher**: rofi
- **Notifications**: dunst
- **Theme**: Catppuccin Mocha
- **Font**: MesloLGLDZ Nerd Font 10

## Apps (Non‑Electron)
- **Flameshot**: screenshots
- **rclone / Nextcloud**: configs moved to `~/.local/share` with symlinks

## Apps (Electron)
- **VS Code**: Catppuccin Mocha + MesloLGLDZ
- **Obsidian**: Catppuccin snippet + MesloLGLDZ
- **Joplin**: removed
- **Discord / Whatsdesk / Postman / FreeTube**: native dark (no mods)

## CLI Extras
- **bat**: Catppuccin Mocha
- **btop**: Catppuccin Mocha
- **yazi**: Catppuccin Mocha
- **lnav**: Catppuccin Mocha
- **cava**: pulse input
- **ranger**: removed

## Duplicates Decisions
- Removed: alacritty, ranger, joplin, niri, Albert, CopyQ
- Kept: i3, kitty, brave/chromium, yazi, Rofi, clipmenu

## Maintenance
- Backup timer: `restic-backup.timer` (sábado 02:00, persistente)
- Secret scan: `scripts/check-secrets.sh`
- Backup excludes template: `docs/backup-excludes.txt`
- i3 workspaces mapping is auto-generated: `stow/i3/.config/i3/workspaces.local.conf` (do not commit)
- Neovim lazy state: `~/.local/state/nvim/lazy` (safe to clear if plugin state breaks)
- Shortcuts doc: regenerate with `bash ./scripts/generate_shortcuts_doc.sh` after keybinding changes
- Doctor JSON: `bash ./scripts/doctor.sh --json` (parseable status)
- Status doc: update this file manually when stack changes
