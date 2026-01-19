# README-BOOTSTRAP (EN)

Practical guide to deploy these dotfiles on a clean install.

Supported environments:
- Desktop Linux: Arch / Debian/Ubuntu / Fedora
- WSL2: CLI-only mode (no i3/polybar/picom)

> Important: `scripts/bootstrap.sh` and `scripts/rollback.sh` modify `$HOME`.
> Always run `--dry-run` first.

## 1) Clone

```bash
cd ~
git clone https://github.com/<your-user>/dotfiles.git
cd dotfiles
```

### Submodules (tmux/vim plugins)

This repo tracks tmux/vim plugins as git submodules:

```bash
git submodule update --init --recursive
```

(Alternative: `bash ./scripts/bootstrap.sh --init-submodules`.)

## 2) Install dependencies (multi-distro)

Use `scripts/install_deps.sh`. It detects your distro and reads:

- `pkglist-arch.txt`
- `pkglist-debian.txt`
- `pkglist-fedora.txt`
- `pkglist-wsl.txt`

Core CLI (recommended first):

```bash
bash ./scripts/install_deps.sh --core
```

Core + GUI (desktop only):

```bash
bash ./scripts/install_deps.sh --all
# or
bash ./scripts/install_deps.sh --core --gui
```

Notes:
- On WSL2 the script forces core-only.
- Missing packages are reported so you can tweak the pkglist.

## 3) Bootstrap (Stow + backup + manifest)

Dry run:

```bash
bash ./scripts/bootstrap.sh --dry-run
```

Apply (interactive):

```bash
bash ./scripts/bootstrap.sh
```

Bootstrap behavior:
- Detects conflicts (existing targets that are not symlinks)
- Moves them into `.backups/<TS>/`
- Creates symlinks via `stow`
- Writes `.manifests/<TS>.manifest`

Useful flags:
- `--core-only` (skip GUI; WSL/servers)
- `--gui` (force GUI on desktop)
- `--yes` (no prompt)
- `--init-submodules`

## 4) After bootstrap

- tmux: run `tmux`, then `prefix + I` to install TPM plugins.
- Neovim: open `nvim`, run `:Lazy sync` / `:Mason`.

## 5) Rollback

Latest:

```bash
bash ./scripts/rollback.sh latest
```

By timestamp:

```bash
bash ./scripts/rollback.sh <timestamp>
```

Explicit manifest:

```bash
bash ./scripts/rollback.sh --manifest .manifests/<timestamp>.manifest
```

Useful options:
- `--dry-run` to preview actions
- `--core-only` to skip GUI (only when NO manifest)
- `--gui` to force GUI (only when NO manifest)
- `--yes` to skip prompts

Rollback:
- `stow -D` to remove symlinks
- `rsync` to restore `.backups/<TS>/` (saving conflicts into
  `~/.dotfiles_rollback_conflicts_<TS>`)
