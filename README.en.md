# Dotfiles · Linux (Arch/Debian/Fedora/WSL2)

This repo is a GNU Stow–based dotfiles setup focused on a fast, consistent
workflow (tmux + Neovim + CLI helpers). On desktop Linux it also includes an i3
stack (kitty/rofi/polybar/picom/dunst).

- Spanish docs: `README.md`
- Bootstrap guide (ES): `README-BOOTSTRAP.md`
- Bootstrap guide (EN): `README-BOOTSTRAP.en.md`

## Quick start

Clone:

```bash
git clone https://github.com/<your-user>/dotfiles.git
cd dotfiles
```

Initialize submodules (tmux/vim plugins are tracked as git submodules):

```bash
git submodule update --init --recursive
```

Install deps (core CLI):

```bash
bash ./scripts/install_deps.sh --core
```

Install also GUI packages (desktop only; WSL2 is core-only):

```bash
bash ./scripts/install_deps.sh --all
```

Bootstrap (always dry-run first):

```bash
bash ./scripts/bootstrap.sh --dry-run
bash ./scripts/bootstrap.sh
```

Rollback:

```bash
bash ./scripts/rollback.sh latest
```

## Local overrides / secrets

Do not commit secrets or machine-specific identity. Use local, untracked files:

- `~/.bashrc_local`
- `~/.gitconfig_local`

(See `README.md` for examples.)
