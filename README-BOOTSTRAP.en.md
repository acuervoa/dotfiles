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

### Submodules

This repo does not use submodules.

## 2) Install dependencies (multi-distro)

Use `scripts/install_deps.sh`. It detects your distro and reads:

- `pkglist-arch.txt`
- `pkglist-debian.txt`
- `pkglist-fedora.txt`

WSL2 (Ubuntu/Debian) uses `pkglist-debian.txt`.

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

### WSL2 (Ubuntu/Debian)

Besides the apt packages, on Debian/Ubuntu `install_deps.sh`:
- installs **Neovim** from the official tarball into `~/.local/opt/nvim` (the
  config needs ≥ 0.11 and Ubuntu 24.04's apt ships 0.9) and links it at
  `~/.local/bin/nvim`;
- installs the **tree-sitter** CLI into `~/.local/bin` (nvim-treesitter builds
  parsers with it; the C compiler comes from `build-essential`);
- links `bat` → `batcat` and `fd` → `fdfind` in `~/.local/bin`.

`starship`, `mise`, `atuin`, `difftastic` and `ripgrep-all` are not in apt:
they are optional and bash only uses them when present.

Reopen the shell after bootstrap so `~/.local/bin` is on PATH.

## 3) Preflight checks (doctor/status)

Before touching `$HOME`, you can run these read-only checks:

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

- `doctor.sh` validates dependencies, profiles, and stow conflicts.
- `status.sh` summarizes host/profile, package list, and latest manifest/backup.

## 4) Bootstrap (Stow + backup + manifest)

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

Alternatives:
- `bash ./scripts/apply.sh` (doctor + dry-run + confirmation in one step)
- `bash ./scripts/update.sh` (git pull ff-only + apply)

Useful flags:
- `--core-only` (skip GUI; WSL/servers)
- `--gui` (force GUI on desktop)
- `--yes` (no prompt)

Quick examples:
- WSL2 / CLI-only: `bash ./scripts/bootstrap.sh --core-only`
- Desktop (force GUI): `bash ./scripts/bootstrap.sh --gui`

## 5) After bootstrap

- tmux: run `tmux`, then `prefix + I` to install TPM plugins.
- Neovim: open `nvim`, run `:Lazy sync` / `:Mason`.

Quick troubleshooting:
- Missing theme/plugin in Neovim: run `:Lazy sync` and restart `nvim`.
- Missing LSPs/linters/formatters: check `:Mason` and `:CheckHealth`.

Optional post-bootstrap verification:
- `bash ./scripts/verify.sh`
- `bash ./scripts/check-secrets.sh --all`

`verify.sh` summary:
- `bash ./scripts/verify.sh` (check.sh + check-secrets + nvim checkhealth)
- `bash ./scripts/verify.sh --nvim-config` (loads `config.options` headless)

## 6) Rollback

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
