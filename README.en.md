# Dotfiles · Linux (Arch/Debian/Fedora/WSL2)

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

Init submodules (tmux/vim plugins):
```bash
git submodule update --init --recursive
```

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
- **Bash library** (`stow/bash/.bash_lib`):
  - nav: `fo` (FO_EXCLUDES, FO_DEFAULT_ROOT, FO_AUTO_CD), `cb` with OSC52 fallback.
  - git: `gp` safe push (force/lease with confirm), `ggraph`, `glast`.
  - docker: `docps`, `dlogs`, `dsh` (DSH_SHELL), `dorebuild`.
  - misc: `fhist`, `envswap` (600 perms), `dev/qa/rtest/rserve/rqa`, tmux helper `ts`.
- **NeoVim (≥0.11)**: lazy.nvim, Mason v2, Treesitter extended (JS/TS/Python/Go/Rust/PHP), LSP/DAP, conform + nvim-lint, overseer + harpoon, neotest, tmux-navigator.
- **tmux**: prefix `Ctrl+s`, thumbs/copycat/fzf/open, session shortcuts/popups (lazygit/btop/tmux-fzf), nvim integration.
- **Desktop**: i3/polybar/picom/dunst/rofi/kitty (Catppuccin Mocha).

---

## Repo layout
```
stow/      # packages for stow (bash, git, nvim, tmux, ...)
scripts/   # bootstrap, rollback, install_deps
.backups/  # backups from bootstrap
.manifests/# manifests of applied operations
pkglist-*.txt
.gitmodules
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

---

## Secrets / local overrides
Keep secrets out of git. Examples:
`~/.bashrc_local`, `~/.gitconfig_local` (see README.md for snippets).

---

## License
[MIT](LICENSE)
