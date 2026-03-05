#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/check-secrets.sh [options]

Scans tracked files for obvious secret patterns.

Options:
  -h, --help   Show this help
  --all        Include untracked files (excluding .gitignored); can be slow
USAGE
}

INCLUDE_UNTRACKED=false
PYTHON_BIN=""

while (($# > 0)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --all)
    INCLUDE_UNTRACKED=true
    ;;
  *)
    printf '[ERROR] Unknown option: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
elif command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
else
  printf '[ERROR] python no está instalado (requiere python o python3)\n' >&2
  exit 1
fi

INCLUDE_UNTRACKED="$INCLUDE_UNTRACKED" REPO_ROOT="$repo_root" "$PYTHON_BIN" - <<'PY'
import os
import re
import subprocess
import sys

repo = os.environ.get("REPO_ROOT")
if not repo:
    repo = os.path.abspath(os.getcwd())

include_untracked = os.environ.get("INCLUDE_UNTRACKED") == "true"

try:
    files = subprocess.check_output(["git", "-C", repo, "ls-files"], text=True).splitlines()
except Exception as e:
    print(f"error: git ls-files failed: {e}")
    sys.exit(2)

if include_untracked:
    try:
        untracked = subprocess.check_output(
            ["git", "-C", repo, "ls-files", "-o", "--exclude-standard"],
            text=True,
        ).splitlines()
        files = sorted(set(files + untracked))
    except Exception as e:
        print(f"error: git ls-files -o failed: {e}")
        sys.exit(2)

aws_access = "".join(map(chr, [65,87,83,95,65,67,67,69,83,83,95,75,69,89,95,73,68]))
aws_secret = "".join(map(chr, [65,87,83,95,83,69,67,82,69,84,95,65,67,67,69,83,83,95,75,69,89]))
patterns = [
    re.compile(aws_access + "|" + aws_secret),
    re.compile(r"(?i)api[_-]?key\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}"),
    re.compile(r"(?i)client[_-]?secret\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}"),
    re.compile(r"(?i)password\s*[:=]\s*['\"]?\S{8,}"),
    re.compile(r"(?i)token\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}"),
    re.compile(r"(?i)authorization:\s*bearer\s+"),
]

deny_ext = {".png", ".jpg", ".jpeg", ".gif", ".pdf", ".zip", ".gz", ".tar", ".xz", ".7z"}
deny_prefixes = (".git/", ".backups/", ".manifests/")

hits = []
for rel in files:
    if rel.startswith(deny_prefixes):
        continue
    _, ext = os.path.splitext(rel)
    if ext.lower() in deny_ext:
        continue

    path = os.path.join(repo, rel)
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception:
        continue

    lines = content.splitlines()
    for pat in patterns:
        for idx, line in enumerate(lines, start=1):
            if pat.search(line):
                hits.append((rel, idx, pat.pattern))
                break
        if hits and hits[-1][0] == rel:
            break

if hits:
    print("Potential secrets detected:")
    for rel, line_no, pat in hits:
        print(f"- {rel}:{line_no} (matched: {pat})")
    sys.exit(1)

print("No obvious secrets found in tracked files.")
PY
