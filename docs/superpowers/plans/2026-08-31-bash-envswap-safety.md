# Bash envswap Safety Barriers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Protect `envswap use` with explicit confirmation and guarantee unique, private backups without exposing `.env` contents.

**Architecture:** `envswap list` remains unchanged. `envswap use` validates the source, confirms before any copy, allocates a backup name using timestamp/PID plus an existence-checking counter, then copies and applies mode `600`.

**Tech Stack:** Bash, GNU coreutils, temporary directories, existing `_confirm` helper.

---

### Task 1: Add red tests for `envswap`

**Files:**
- Create: `tests/bash_envswap_safety_test.sh`
- Reference: `stow/bash/.bash_lib/misc.sh`
- Reference: `stow/bash/.bash_lib/core.sh`

- [x] **Step 1: Build a private temporary fixture**

Create a temporary directory containing `.env` and `.env.staging` with distinct sentinel text, source `core.sh` and `misc.sh` from inside that directory, and use `cmp` only for assertions. Never print either file.

- [x] **Step 2: Test rejection**

Pipe `n` into `envswap use staging`, assert nonzero/abort-safe behavior, assert `.env` is unchanged, and assert no `.env.bak.*` file was created.

- [x] **Step 3: Test confirmed activation and permissions**

Pipe `y` into `envswap use staging`, assert `.env` equals `.env.staging`, assert exactly one backup exists containing the former `.env`, and assert `.env` and the backup have mode `600`.

- [x] **Step 4: Test backup uniqueness**

Restore a different `.env` value and perform a second confirmed swap immediately. Assert at least two backups exist and their paths are distinct; compare the newest backup to the value that was active immediately before the second swap.

- [x] **Step 5: Test `list` remains non-mutating**

Run `envswap list`, assert it lists `staging`, and assert the active `.env` and backup count are unchanged.

- [x] **Step 6: Run the test before implementation**

Run `bash tests/bash_envswap_safety_test.sh`. Expected: FAIL because `use` currently copies without confirmation and backup naming can collide.

### Task 2: Add confirmation and collision-safe backups

**Files:**
- Modify: `stow/bash/.bash_lib/misc.sh`

- [x] **Step 1: Confirm before filesystem mutation**

After validating `.env.<name>` and before creating a backup or copying `.env`, print only the source and destination paths and call `_confirm '¿Continuar? [y/N] '`. Return 0 when rejected.

- [x] **Step 2: Allocate a unique backup path**

When `.env` exists, generate a base using `date +%Y%m%d-%H%M%S` and `$$`, then increment a numeric suffix while the candidate exists. Use the first unused candidate; do not overwrite an existing backup.

- [x] **Step 3: Preserve the existing copy contract**

Copy the active `.env` to the allocated backup, apply `chmod 600` to it, copy `.env.<name>` to `.env`, apply `chmod 600` to `.env`, and retain the existing success/error messages without printing contents.

- [x] **Step 4: Run focused tests**

Run `bash tests/bash_envswap_safety_test.sh`; expect all cases to PASS.

### Task 3: Verify compatibility and commit

**Files:**
- Modify: `tests/bash_envswap_safety_test.sh`
- Modify: `stow/bash/.bash_lib/misc.sh`

- [x] **Step 1: Verify syntax and runtime type**

Run `bash -n stow/bash/.bash_lib/misc.sh` and source a clean shell to print only `type -t envswap`. Expected: syntax exit 0 and `function`.

- [x] **Step 2: Run the complete Bash suite**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh; do bash -n "$file"; done
git diff --check
```

Expected: every test exits 0, every Bash file parses, and no whitespace errors are reported.

- [x] **Step 3: Inspect scope and secret safety**

Run `git diff -- stow/bash/.bash_lib/misc.sh tests/bash_envswap_safety_test.sh`. Confirm no `.env` contents, `.bashrc_local`, tmux, i3, Docker, or Laravel files changed.

- [x] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bash_lib/misc.sh tests/bash_envswap_safety_test.sh
git commit -m "feat(bash): protect envswap activation"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
