---
name: run-checks
description: Run this dotfiles repo's full local check matrix (verify.sh plus relevant tests/*_test.sh) in one shot. Use before claiming a change is done, before a commit, or when asked to "verify" or "run the checks/tests".
---

This repo has no single test-runner script — `tests/` holds ~30 independent
`*_test.sh` files with no aggregator. Run the matrix in this order:

1. `bash ./scripts/verify.sh` — runs `check.sh` (bash -n + shellcheck + shfmt -d
   over `scripts/*.sh`, `scripts/lib/*.sh`, `stow/bash/.bash_lib/*.sh`) plus
   `check-secrets.sh`.
2. Run only the `tests/*_test.sh` files relevant to what changed — match by
   filename prefix to the area touched (e.g. edited `stow/bash/...` →
   `bash_*_test.sh`; edited `stow/nvim/...` → `nvim_*_test.sh`; edited
   `stow/i3/...` → `i3_*_test.sh`). Run each with `bash tests/<name>_test.sh`.
3. If the change touches desktop configs broadly, also run
   `bash ./scripts/check-desktop-configs.sh --static`.
4. If unsure which tests apply, or the change is repo-wide, run all of
   `tests/*_test.sh` in a loop.

Report pass/fail per script actually run — don't claim "verified" without
having executed at least step 1.
