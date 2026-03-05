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
- **Flameshot**, **Albert**, **CopyQ**: Catppuccin themes
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
- Removed: alacritty, ranger, joplin
- Kept: i3 (primary), niri (secondary), kitty, brave/chromium, yazi, rofi/albert

## Maintenance
- Monthly cleanup timer: `cleanup-configs.timer`
- Secret scan: `scripts/check-secrets.sh`
- Backup excludes template: `docs/backup-excludes.txt`
