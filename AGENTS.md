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

Quick verification:
- `bash ./scripts/verify.sh` (check.sh + check-secrets + optional nvim health)
- `bash ./scripts/verify.sh --nvim-config` (also loads config.options)

Useful when scanning for secrets:
- `bash ./scripts/check-secrets.sh --all` (includes untracked; can be slow)

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
- All-in-one: `bash ./scripts/verify.sh`

Examples:
- `bash -n scripts/bootstrap.sh` + `shellcheck scripts/bootstrap.sh`
- `bash -n stow/bash/.bash_lib/aliases.sh` + `shellcheck stow/bash/.bash_lib/aliases.sh`
- `nvim --headless "+lua require('config.options')" +qa`

Note: Neovim config integrates external project tooling (e.g. `pytest`, `go test`,
`phpunit`) for *other repos*, not for this dotfiles repo.

## Code style guidelines

### General
- Keep diffs small; avoid drive-by reformatting.
- Prefer updating existing scripts/configs over adding new ones.
- Add new settings near related ones; don’t scatter knobs across files.
- Avoid hardcoding machine-specific paths; prefer env vars (`$HOME`, `$XDG_*`).
- Keep changes reversible and easy to rollback.

### Git + commits
- Prefer Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- This repo’s `commit-msg` hook rejects messages containing `WIP`/`tmp`.
- Do not bypass hooks (`--no-verify`) unless explicitly requested.

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
  - Variables are `snake_case`; keep existing casing per file.

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
- Error handling:
  - Prefer `vim.notify` for user-facing errors; avoid hard `error(...)` in config paths.
- Tooling (optional on host):
  - Format via `stylua`.
  - Lint via `luacheck`.

### Config files (toml/yaml/ini/rasi/vim/tmux)
- Match the file’s existing formatting and quoting style.
- Prefer minimal, reversible changes (dotfiles should be easy to rollback).
- If a setting is version-sensitive, add a short inline comment.
- Keep key ordering and section grouping consistent with the file.

## Stow package conventions
- A package’s internal paths should mirror the target paths in `$HOME`/`$XDG_CONFIG_HOME`.
- Prefer adding/adjusting config inside `stow/<pkg>/...` rather than editing files in `$HOME`.
- New files should match target filenames/locations (avoid ad-hoc suffixes).
- If you add a new top-level package that should be deployed by scripts, also update:
  - `HOME_PKGS` / `CONFIG_PKGS` in `scripts/bootstrap.sh` and `scripts/rollback.sh`.
- Avoid machine-specific absolute paths in configs; use env vars and XDG paths.

## Safety
- Treat any command that touches `$HOME` as potentially destructive.
- Avoid `rm -rf` patterns unless explicitly requested; prefer reversible changes.
- If asked to run bootstrap/rollback, suggest `--dry-run` first and call out what will change.

Do:
- Use `stow -n` first when unsure.
- Call out any `$HOME`-modifying command before running it.

Don’t:
- Run `bootstrap.sh`/`rollback.sh` without an explicit request.
- Restow or apply packages without a dry-run when behavior is unclear.

## Useful repo commands
- Fast search: `rg <pattern>`
- List files: `rg --files`
- Show stow packages: `ls stow`
- Verify (all-in-one): `bash ./scripts/verify.sh`
- Doctor (JSON): `bash ./scripts/doctor.sh --json`
- Troubleshooting: `docs/troubleshooting.md`

## CI
- Workflow: `.github/workflows/ci.yml` (runs `scripts/check.sh` and `scripts/check-secrets.sh`)

## Common workflows (Stow)
- Preview a package (safe): `stow -n -v -t "$HOME" <pkg>`
- Apply a package: `stow -v -t "$HOME" <pkg>`
- Restow after edits: `stow -R -v -t "$HOME" <pkg>`
- Remove a package: `stow -D -v -t "$HOME" <pkg>`

Notes:
- Config packages under `stow/` still target `$HOME` (paths include `.config/...`).
- Prefer `-n` dry-run before any stow operation.

## Vendored / third-party code
Avoid editing these unless explicitly asked:
- `stow/yazi/.config/yazi/plugins/**` (often vendored)
