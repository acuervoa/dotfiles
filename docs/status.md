# Stack Status

Date: 2026-09-04

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
- **Albert**: launcher, Catppuccin Mocha theme (reinstated — see Duplicates Decisions)
- **CopyQ**: clipboard history manager, Catppuccin Mocha theme (reinstated — see Duplicates Decisions)
- **restic**: backup (see Maintenance)

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
- **atuin**: shell history sync/search
- **gh-dash**: GitHub PR/issue TUI dashboard
- **mise**: runtime/tool version manager
- **ranger**: removed

## Duplicates Decisions
- Removed: alacritty, ranger, joplin, niri
- Kept: i3, kitty, brave/chromium, yazi, Rofi, clipmenu, Albert, CopyQ
- 2026-09-04: Albert and CopyQ were live in `$HOME` but missing from
  `stow/dotfiles/.config/dotfiles/hosts/default.sh`, so bootstrap/rollback
  didn't know about them. Wired back in — treat as kept, not removed.

## Maintenance
- Backup timer: `restic-backup.timer` (sábado 02:00, persistente)
- Secret scan: `scripts/check-secrets.sh`
- Backup excludes template: `docs/backup-excludes.txt`
- i3 workspaces mapping is auto-generated: `stow/i3/.config/i3/workspaces.local.conf` (do not commit)
- Neovim lazy state: `~/.local/state/nvim/lazy` (safe to clear if plugin state breaks)
- Shortcuts doc: regenerate with `bash ./scripts/generate_shortcuts_doc.sh` after keybinding changes
- Doctor JSON: `bash ./scripts/doctor.sh --json` (parseable status)
- Status doc: update this file manually when stack changes
- Package profile: `stow/dotfiles/.config/dotfiles/hosts/{default,<hostname>}.sh`
  is the source of truth for what `bootstrap.sh`/`rollback.sh` deploy — check
  it, not this doc, when in doubt about a specific package.
- Test suite: `bash ./scripts/run_tests.sh` (23 tests deterministas; la
  integración Neovim/ble.sh corre en `.github/workflows/ci-integration.yml`), now wired into
  `scripts/verify.sh` and CI (`.github/workflows/ci.yml`).
- Known gap: `stow/{gtk-3.0,gtk-4.0}` are stowed on this host but not yet
  wired into any host profile.
