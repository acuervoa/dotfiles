# Security Hardening Notes

This repo is intended to keep configuration only. Secrets should live outside
the repo and be symlinked where needed.

## Principles
- Keep secrets in `~/.local/share` (or a password manager), not in dotfiles.
- Use `.gitignore` for common secret file patterns.
- Restrict permissions on sensitive files (e.g. `chmod 600`).

## Recommended structure
- rclone: `~/.local/share/rclone/rclone.conf` -> symlink to `~/.config/rclone/rclone.conf`
- Nextcloud: `~/.local/share/Nextcloud/nextcloud.cfg` -> symlink to `~/.config/Nextcloud/nextcloud.cfg`

## Checks
Run this before pushing:
```
./scripts/check-secrets.sh
```

If it fails, remove secrets and replace with `.example` templates.
