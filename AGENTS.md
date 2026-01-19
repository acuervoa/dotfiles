# AGENTS.md — dotfiles (Arch Linux)

Dotfiles repo managed with GNU Stow (Bash/Git/tmux/(Neo)Vim/i3/etc.).
Agentic coding tools should be conservative: minimal diffs, no secrets, and avoid
anything destructive unless explicitly requested.

## Repo layout
- `stow/` = stow “packages” (symlink sources)
  - to `$HOME`: `stow/{bash,git,tmux,vim}`
  - to `$HOME/.config`: `stow/{atuin,blesh,dunst,i3,kitty,lazygit,mise,nvim,picom,polybar,rofi,yazi}`
- `scripts/` = entrypoints (`bootstrap.sh`, `rollback.sh`, `install_deps.sh`)
- `.backups/<TIMESTAMP>/` = backups created by bootstrap

## Cursor / Copilot rules
- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot rules found in `.github/copilot-instructions.md`.

## Apply / install commands
No traditional “build”; changes are applied via Stow.

- Install deps (interactive): `bash ./scripts/install_deps.sh --core` (add `--gui` on desktop)
- Bootstrap (dry-run first):
  - `bash ./scripts/bootstrap.sh --dry-run`
  - `bash ./scripts/bootstrap.sh`
- Rollback:
  - `bash ./scripts/rollback.sh latest`
  - `bash ./scripts/rollback.sh <TIMESTAMP>`

Safety notes:
- `bootstrap.sh` and `rollback.sh` modify `$HOME`; treat them as destructive.
- Prefer `--dry-run` and never run these unexpectedly.

## Lint / format / smoke checks
Prefer focused checks on the files you touched.

### Shell
- Syntax (all): `bash -n scripts/*.sh stow/bash/.bash_lib/*.sh`
- Syntax (single): `bash -n scripts/bootstrap.sh`
- Lint (all): `shellcheck scripts/*.sh stow/bash/.bash_lib/*.sh`
- Lint (single): `shellcheck scripts/rollback.sh`

### Formatting
- `stow/bash/.bash_lib/*.sh` is generally 2-space indented; keep local style.
- When reformatting is needed, use `shfmt` and keep diffs readable:
  - `shfmt -w -i 2 stow/bash/.bash_lib`
  - `shfmt -w -i 2 scripts`

### Neovim (headless sanity)
- `nvim --headless "+checkhealth" +qa`
- `nvim --headless "+lua require('config.options')" +qa`

### Generated docs
- Regenerate shortcuts: `bash ./scripts/generate_shortcuts_doc.sh`

## Tests (and “single test” equivalents)
There is no repo-wide automated test suite.

Use these instead:
- Single script: `bash -n <file>` + `shellcheck <file>`
- Bootstrap safety: `bash ./scripts/bootstrap.sh --dry-run`
- Neovim loads: `nvim --headless "+lua require('...')" +qa`

Note: Neovim config integrates external project tooling (e.g. `pytest`, `go test`,
`phpunit`) for *other repos*, not for this dotfiles repo.

## Code style guidelines

### General
- Keep diffs small; avoid drive-by reformatting.
- Prefer updating existing scripts/configs over adding new ones.
- Add new settings near related ones; don’t scatter knobs across files.
- Avoid hardcoding machine-specific paths; prefer env vars (`$HOME`, `$XDG_*`).

### Git + commits
- Prefer Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- This repo’s `commit-msg` hook rejects messages containing `WIP`/`tmp`.

### Secrets & sensitive files (IMPORTANT)
- Put machine-specific/secret values in untracked local files:
  - `~/.bashrc_local`, `~/.gitconfig_local`, etc.
- Shared git hooks live in `stow/git/.git-hooks` and are stowed to `~/.git-hooks`.
  - `pre-commit` scans staged content for common secret/debug patterns.
  - It blocks committing: `.env`, `.env.local`, `.env.prod`, `docker-compose.override.yml`.

### Bash / shell
Applies to `scripts/*.sh` and `stow/bash/.bash_lib/*.sh`.

- Entrypoints:
  - Use `#!/usr/bin/env bash` and `set -euo pipefail`.
  - Use clear `usage()` output for CLI flags.
- Libraries:
  - Prefer `return` (avoid `exit`).
  - Prefix internal helpers with `_` (e.g. `_req`, `_confirm`).
- Error handling:
  - Print errors to stderr (`>&2`) and return non-zero.
  - Prefer `command || return 1` / `if ! command; then ...; fi`.
  - Avoid silent failures; be explicit when skipping optional tools.
- Safety:
  - Quote variables by default.
  - Use `local` variables inside functions.
  - Ask confirmation before destructive actions (pattern: `_confirm`).
- Naming:
  - Function names are short but descriptive (`rgf`, `docps`, `dlogs`); keep existing style.

### Lua (Neovim config)
Applies under `stow/nvim/.config/nvim`.

- Module shape:
  - Prefer `local M = {}` + `return M`.
  - Keep `require(...)` near the top; avoid circular requires.
- Formatting & style:
  - Follow file-local indentation (many Lua files use tabs).
  - Prefer `snake_case` locals (`ensure_dir`) and clear names over abbreviations.
- Imports / dependencies:
  - Do not add new plugins casually; if you do, also consider `lazy-lock.json` impact.
  - Keep plugin specs in `stow/nvim/.config/nvim/lua/plugins/*.lua`.
  - Keep language-specific config in `stow/nvim/.config/nvim/lua/lang/*.lua`.
- Tooling (optional on host):
  - Format via `stylua`.
  - Lint via `luacheck`.

### Config files (toml/yaml/ini/rasi/vim/tmux)
- Match the file’s existing formatting and quoting style.
- Prefer minimal, reversible changes (dotfiles should be easy to rollback).
- If a setting is version-sensitive, add a short inline comment.

## Stow package conventions
- A package’s internal paths should mirror the target paths in `$HOME`/`$XDG_CONFIG_HOME`.
- Prefer adding/adjusting config inside `stow/<pkg>/...` rather than editing files in `$HOME`.
- If you add a new top-level package that should be deployed by scripts, also update:
  - `HOME_PKGS` / `CONFIG_PKGS` in `scripts/bootstrap.sh` and `scripts/rollback.sh`.
- Avoid machine-specific absolute paths in configs; use env vars and XDG paths.

## Safety
- Treat any command that touches `$HOME` as potentially destructive.
- Avoid `rm -rf` patterns unless explicitly requested; prefer reversible changes.
- If asked to run bootstrap/rollback, suggest `--dry-run` first and call out what will change.

## Useful repo commands
- Fast search: `rg <pattern>`
- List files: `rg --files`
- Show stow packages: `ls stow`

## Vendored / third-party code
Avoid editing these unless explicitly asked:
- `stow/vim/.vim/plugged/**`
- `stow/tmux/.tmux/plugins/**`
- `stow/yazi/.config/yazi/plugins/**` (often vendored)
