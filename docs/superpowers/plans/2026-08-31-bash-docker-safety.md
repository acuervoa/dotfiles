# Bash Docker/Laravel Safety Barriers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Protect Docker/Laravel operations that mutate data, clear caches, or rebuild containers while keeping query, shell, test, and analysis commands immediate.

**Architecture:** Confirmation-aware functions own `pmig`, `pseed`, `pclear`, and `dorebuild`. The existing `dcrb` alias becomes a thin function delegating to `dorebuild`, so the rebuild contract has one owner. Tests use fake Docker executables and temporary Compose projects.

**Tech Stack:** Bash, Docker Compose command wrappers, existing `_confirm`/`_have_compose` helpers, shell tests.

---

### Task 1: Add red tests for Docker/Laravel safety

**Files:**
- Create: `tests/bash_docker_safety_test.sh`
- Reference: `stow/bash/.bash_lib/docker.sh`
- Reference: `stow/bash/.bash_lib/core.sh`

- [x] **Step 1: Build the fake Compose harness**

Create a temporary `docker` executable that logs every argument and returns successful output for `docker compose version` and `docker compose ps --services`; make other calls succeed after logging. Create a temporary project containing `compose.yml` and source `core.sh` plus `docker.sh` from inside that project.

- [x] **Step 2: Test rejection before Docker resolution**

For `pmig`, `pseed`, `pclear`, and `dorebuild`, pipe `n` into each command and assert the Docker log remains empty. This proves confirmation occurs before Compose discovery or execution.

- [x] **Step 3: Test confirmed argument contracts**

Pipe `y` into each protected command and assert the logged calls preserve these exact operations: `compose exec php php artisan migrate`, `compose exec php php artisan db:seed`, the three `compose exec php php artisan ...:clear` calls for `pclear`, and `compose build --no-cache` followed by `compose up -d` for `dorebuild`.

- [x] **Step 4: Test `dcrb` delegation and fast commands**

Assert `dcrb` produces the same two rebuild calls through `dorebuild`, and assert `p`, `part`, `ptest`, `pstan`, `pint`, and `proute` do not read confirmation input before delegating.

- [x] **Step 5: Run the test before implementation**

Run `bash tests/bash_docker_safety_test.sh`. Expected: FAIL because the protected commands execute without confirmation and `dcrb` is still an alias.

### Task 2: Protect rebuild and Laravel mutation commands

**Files:**
- Modify: `stow/bash/.bash_lib/docker.sh`

- [x] **Step 1: Add a single protected rebuild implementation**

Update `dorebuild` so it prints the no-cache rebuild warning, calls `_confirm '¿Continuar? [y/N] '`, returns without calling `_have_compose` when rejected, and only then runs the existing `build --no-cache "$@" && up -d` sequence.

- [x] **Step 2: Add confirmation to `pmig` and `pseed`**

Before `_docker_compose_exec_php`, print the operation and call `_confirm`; return 0 without invoking Compose when rejected. Preserve all arguments after the Artisan command.

- [x] **Step 3: Add confirmation to `pclear`**

Before the first cache-clear operation, print that view, application, and config caches will be cleared, call `_confirm`, and return 0 on rejection. Preserve the existing three-command sequence.

- [x] **Step 4: Run focused tests**

Run `bash tests/bash_docker_safety_test.sh`; expect protected command tests to pass while the alias/delegation case remains red until Task 3.

### Task 3: Make `dcrb` a single-owner delegation

**Files:**
- Modify: `stow/bash/.bash_aliases`
- Modify: `stow/bash/.bash_lib/docker.sh`

- [x] **Step 1: Remove the direct rebuild alias**

Delete only `alias dcrb='docker compose build --no-cache && docker compose up -d'` from `.bash_aliases`.

- [x] **Step 2: Add the delegation function**

Add a public `dcrb()` function in `docker.sh` with `# @cmd dcrb` that calls `dorebuild "$@"`. It must not duplicate confirmation or Compose command logic.

- [x] **Step 3: Run focused tests**

Run `bash tests/bash_docker_safety_test.sh`; expected result is all PASS.

### Task 4: Verify compatibility and commit

**Files:**
- Modify: `tests/bash_docker_safety_test.sh`
- Modify: `stow/bash/.bash_aliases`
- Modify: `stow/bash/.bash_lib/docker.sh`

- [x] **Step 1: Verify runtime types**

Source `.bashrc` in a clean shell and print only `type -t dcrb`, `type -t dorebuild`, `type -t pmig`, `type -t pseed`, and `type -t pclear`. Expected: `function` for all five.

- [x] **Step 2: Run the full Bash suite and syntax checks**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh; do bash -n "$file"; done
git diff --check
```

Expected: every test exits 0, every Bash file parses, and no whitespace errors are reported.

- [x] **Step 3: Inspect scope and secret safety**

Run `git diff -- stow/bash/.bash_aliases stow/bash/.bash_lib/docker.sh tests/bash_docker_safety_test.sh`. Confirm no tmux/i3 files, `.env` contents, local override files, or unrelated commands changed.

- [x] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bash_aliases stow/bash/.bash_lib/docker.sh tests/bash_docker_safety_test.sh
git commit -m "feat(bash): protect Docker mutation shortcuts"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
