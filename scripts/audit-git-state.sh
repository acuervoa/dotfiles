#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

printf '# Git state audit\n\n'
printf '%s\n' "- Repository: $repo_root"
printf '%s\n' "- Branch: $(git branch --show-current)"
printf '%s\n' "- Status: $(git status --porcelain=v1 | wc -l | tr -d ' ') changed path(s)"
printf '%s\n' "- Upstream: $(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null || printf 'unconfigured')"
printf '%s\n' "- Hooks path: $(git config --get core.hooksPath || printf 'unset')"
printf '%s\n' "- Latest tag: $(git describe --tags --abbrev=0 2>/dev/null || printf 'none')"

printf '\n## Local branches\n\n'
git branch -vv
printf '\n## Worktrees\n\n'
git worktree list
printf '\n## Dangling objects (informational)\n\n'
git fsck --full --no-progress 2>/dev/null | sed -n '1,120p' || true
printf '\nNo branches, worktrees or objects were modified.\n'
