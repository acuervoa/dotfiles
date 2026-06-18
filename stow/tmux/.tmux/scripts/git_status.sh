#!/usr/bin/env bash
dir="${1:-$PWD}"
cd "$dir" 2>/dev/null || exit 0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    printf '%s ✗' "$branch"
else
    printf '%s' "$branch"
fi
