---
name: new-stow-package
description: Scaffold a new stow package under stow/<pkg> for this dotfiles repo, and make sure it actually gets deployed. Use when the user asks to add a new tool/app's dotfiles, or add a new stow package.
---

Adding `stow/<pkg>/...` alone is not enough — `bootstrap.sh`/`rollback.sh`
only touch packages listed in their arrays. Missing this step is the most
common way a new package silently never gets symlinked.

Steps:

1. Create `stow/<pkg>/...` mirroring the real target path:
   - Targets `$HOME` directly (like `bash`, `git`, `tmux`): put files at
     `stow/<pkg>/.<file>` (e.g. `stow/<pkg>/.somerc`).
   - Targets `$HOME/.config` (like `nvim`, `i3`, `kitty`): put files at
     `stow/<pkg>/.config/<pkg>/...`.
2. Add `<pkg>` to the correct array in **both** `scripts/bootstrap.sh` and
   `scripts/rollback.sh`:
   - `HOME_PKGS` if it targets `$HOME` directly.
   - `CONFIG_PKGS` if it targets `$HOME/.config`.
3. Avoid machine-specific absolute paths inside the package's files — use
   `$HOME`/`$XDG_*` env vars.
4. Verify before applying:
   - `stow -n -v -t "$HOME" <pkg>` (dry-run, safe)
   - `bash ./scripts/bootstrap.sh --dry-run` (confirms it's picked up)
5. Apply for real only on explicit request:
   - `stow -v -t "$HOME" <pkg>`
6. If the package should appear in generated docs, re-run
   `bash ./scripts/generate_shortcuts_doc.sh` and/or
   `bash ./scripts/generate_tools_doc.sh` as applicable.

Don't restow or run bootstrap non-dry-run without the user explicitly asking.
