#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python - <<'PY'
import os
import re
import subprocess
import sys

repo = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

try:
    files = subprocess.check_output(["git", "-C", repo, "ls-files"], text=True).splitlines()
except Exception as e:
    print(f"error: git ls-files failed: {e}")
    sys.exit(2)

aws_access = "".join(map(chr, [65,87,83,95,65,67,67,69,83,83,95,75,69,89,95,73,68]))
aws_secret = "".join(map(chr, [65,87,83,95,83,69,67,82,69,84,95,65,67,67,69,83,83,95,75,69,89]))
patterns = [
    re.compile(aws_access + "|" + aws_secret),
    re.compile(r"(?i)api[_-]?key\s*[:=]"),
    re.compile(r"(?i)client[_-]?secret\s*[:=]"),
    re.compile(r"(?i)password\s*[:=]"),
    re.compile(r"(?i)token\s*[:=]"),
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

    for pat in patterns:
        if pat.search(content):
            hits.append((rel, pat.pattern))
            break

if hits:
    print("Potential secrets detected:")
    for rel, pat in hits:
        print(f"- {rel} (matched: {pat})")
    sys.exit(1)

print("No obvious secrets found in tracked files.")
PY
