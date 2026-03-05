# Dotfiles · Linux (Arch/Debian/Fedora/WSL2)

![ci](https://github.com/acuervoa/dotfiles/actions/workflows/ci.yml/badge.svg) ![last-commit](https://img.shields.io/github/last-commit/acuervoa/dotfiles?style=flat-square) ![license](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)

GNU Stow–based dotfiles for a fast, consistent workflow (tmux + Neovim + CLI helpers). Desktop includes i3 stack (kitty/rofi/polybar/picom/dunst) themed with Catppuccin Mocha.

- Spanish docs: `README.md`
- Bootstrap guide (ES): `README-BOOTSTRAP.md`
- Bootstrap guide (EN): `README-BOOTSTRAP.en.md`

---

## Quick start

Clone:
```bash
git clone https://github.com/<your-user>/dotfiles.git
cd dotfiles
```

tmux plugins: bootstrap installs TPM + plugins under `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins`.

Install deps:
```bash
bash ./scripts/install_deps.sh --core          # CLI only (WSL-friendly)
bash ./scripts/install_deps.sh --core --gui    # Desktop (GUI)
```

Bootstrap (dry-run first):
```bash
bash ./scripts/bootstrap.sh --dry-run
bash ./scripts/bootstrap.sh
```

Step-by-step guide: `README-BOOTSTRAP.en.md` (preflight, flags, rollback).

Recommended flow:
1. `doctor.sh` + `status.sh` (preflight)
2. `bootstrap.sh --dry-run`
3. `bootstrap.sh`

Alternatives:
- `apply.sh` runs doctor + dry-run + confirmation in one step
- `update.sh` does a git pull (ff-only) then runs `apply.sh`

Preflight (read-only, recommended before touching `$HOME`):
```bash
bash ./scripts/doctor.sh
bash ./scripts/status.sh
```

Doctor JSON (parseable output):
```bash
bash ./scripts/doctor.sh --json
```

Status JSON (parseable output):
```bash
bash ./scripts/status.sh --json
```

Quick verify (all-in-one):
```bash
bash ./scripts/verify.sh
```

Secrets scan (includes untracked; can be slow):
```bash
bash ./scripts/check-secrets.sh --all
```

Manual workflow dispatch (full secrets scan):
- GitHub → Actions → `ci` → Run workflow → set `include_untracked` = true

Rollback:
```bash
bash ./scripts/rollback.sh latest
```

---

## Stack & highlights
- **GNU Stow**: declarative symlinks under `stow/`; manifest + backups in `.manifests/` and `.backups/`.
- **Bootstrap/rollback scripts**: interactive, with dry-run and conflict backups.
- **Local overrides**: `_local` files (e.g. `~/.bashrc_local`, `~/.gitconfig_local`) are auto-loaded and git-ignored.
- **Dynamic docs**: `scripts/generate_shortcuts_doc.sh` builds `SHORTCUTS.md`.
- **Backup excludes**: `docs/backup-excludes.txt` contains suggested exclusions for backups.
- **Stack status**: `docs/status.md` tracks current stack and duplicate decisions.
- **Troubleshooting**: `docs/troubleshooting.en.md` quick fixes.
- **Manifest guide**: `docs/manifest.en.md` manual rollback notes.
- **Docs index**: `docs/README.md` (start here for docs).
- **CI**: GitHub Actions runs `scripts/check.sh` and `scripts/check-secrets.sh` on push/PR.
- **Bash library** (`stow/bash/.bash_lib`):
  - nav: `fo` (FO_EXCLUDES, FO_DEFAULT_ROOT, FO_AUTO_CD), `cb` with OSC52 fallback.
  - git: `gp` safe push (force/lease with confirm), `ggraph`, `glast`.
  - docker: `docps`, `dlogs`, `dsh` (DSH_SHELL), `dorebuild`.
  - misc: `fhist`, `envswap` (600 perms), `dev/qa/rtest/rserve/rqa`, tmux helper `ts`.
- **NeoVim (≥0.11)**: lazy.nvim, Mason v2, Treesitter extended (JS/TS/Python/Go/Rust/PHP), LSP/DAP, conform + nvim-lint, overseer + harpoon, neotest, tmux-navigator.
- **tmux**: prefix `Ctrl+s`, thumbs/copycat/fzf/open, session shortcuts/popups (lazygit/btop/tmux-fzf), nvim integration.
- **Desktop**: i3/polybar/picom/dunst/rofi/kitty (Catppuccin Mocha).

---

## Current stack

- **Core**: bash, kitty, tmux, Neovim, starship
- **WM/UX**: i3 + picom + polybar + rofi + dunst
- **Theme/Font**: Catppuccin Mocha, MesloLGLDZ Nerd Font 10
- **Notes**: Obsidian (Joplin removed)

---

## Repo layout
```
stow/      # packages for stow (bash, git, nvim, tmux, ...)
scripts/   # bootstrap, rollback, install_deps
.backups/  # backups from bootstrap
.manifests/# manifests of applied operations
pkglist-*.txt
```

---

## Manual Stow (alt)
```bash
stow -d stow -t "$HOME" -S bash  # install
stow -d stow -t "$HOME" -D bash  # uninstall
```

---

## Quick checks
```bash
for p in ~/.config/{kitty,lazygit,polybar,picom,i3,dunst,rofi,nvim}; do
  [ -L "$p" ] && echo "OK $p" || echo "MISSING $p"
done
kitty --version; tmux -V; nvim --headless "+checkhealth" +qa
```

Note: `stow/i3/.config/i3/workspaces.local.conf` is auto-generated; do not commit it.

---

## Secrets / local overrides
Keep secrets out of git. Examples:
`~/.bashrc_local`, `~/.gitconfig_local` (see README.md for snippets).

---

## License
[MIT](LICENSE)
