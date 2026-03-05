# Manifest (manual rollback)

Manifests live in `.manifests/<TIMESTAMP>.manifest` and record the symlinks
created by bootstrap.

## Format

Each line follows:

```
LINK <src> -> <dest>
```

Example:

```
LINK /home/user/dotfiles/stow/bash/.bashrc -> /home/user/.bashrc
LINK /home/user/dotfiles/stow/nvim/.config/nvim -> /home/user/.config/nvim
```

## Manual rollback usage

1. Filter `LINK` lines to find created symlinks.
2. Remove symlinks that point to the repo (if you plan to restore backups).
3. Restore backups from `.backups/<TIMESTAMP>/` when needed.

Quick example:

```bash
# List created links
rg '^LINK ' .manifests/<TIMESTAMP>.manifest

# Check where a symlink points
readlink -f ~/.bashrc
```

Notes:
- If a symlink points elsewhere, do not remove it.
- Prefer `bash ./scripts/rollback.sh` when possible.

## FAQ

**Symlink does not match the manifest**

- Do not remove it automatically.
- Check the target with `readlink` and decide case by case.

**How to identify symlinks outside the repo**

- Use `readlink -f <dest>` and verify it starts with the repo path.
- If it does not point to the repo, do not remove it automatically.
