# Bash Git Safety Barriers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Protect force-push and WIP commits from accidental execution or obvious credential files while preserving existing Git command names.

**Architecture:** `gpf` becomes a confirmation-aware function in `git.sh`. `wip` stages as today, then checks only staged pathnames against a conservative sensitive-file pattern before committing. Tests use temporary repositories and command logs; no real repository or secret content is used.

**Tech Stack:** Bash, Git, existing `_confirm`/`_req` helpers, shell tests.

---

### Task 1: Add red tests for Git safety contracts

**Files:**
- Create: `tests/bash_git_safety_test.sh`
- Reference: `stow/bash/.bash_lib/git.sh`
- Reference: `stow/bash/.bash_lib/core.sh`

- [x] **Step 1: Test `gpf` rejection and invocation**

Create a temporary executable `git` wrapper that logs arguments and delegates non-push operations to the real Git binary. Source `core.sh` and `git.sh` with the wrapper first in `PATH`, set `VISUAL=true`, and run `gpf` twice using piped input: `n` must produce no logged `push`, while `y` must log exactly `push --force-with-lease`.

- [x] **Step 2: Test `wip` blocks sensitive staged paths**

In a temporary Git repository, create `.env`, stage it, run `wip`, and assert the commit count remains unchanged. Inspect only `git diff --cached --name-only`; never print file contents.

- [x] **Step 3: Test `wip` permits ordinary staged paths**

In a separate temporary repository, create `README.md`, stage it, run `wip`, and assert the commit count increases to one. Configure a local test identity only inside that temporary repository.

- [x] **Step 4: Run the test before implementation**

Run `bash tests/bash_git_safety_test.sh`. Expected: FAIL because `gpf` is currently an alias and `wip` has no sensitive-path guard.

### Task 2: Convert `gpf` into a protected function

**Files:**
- Modify: `stow/bash/.bash_aliases`
- Modify: `stow/bash/.bash_lib/git.sh`

- [x] **Step 1: Remove the direct alias**

Delete only `alias gpf='git push --force-with-lease'` from `.bash_aliases`; leave all other aliases unchanged.

- [x] **Step 2: Add the protected function**

Add this public function near `gp` in `git.sh`:

```bash
# @cmd gpf  Push force-with-lease protegido
gpf() {
  _req git || return 1
  _git_root_or_die || return 1

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 1
  printf 'Rama actual: %s\n' "$branch" >&2
  printf 'Vas a pushear con --force-with-lease.\n' >&2
  _confirm '¿Seguro? [y/N] ' || return 0
  git push --force-with-lease "$@"
}
```

- [x] **Step 3: Run focused tests**

Run `bash tests/bash_git_safety_test.sh`; expect `gpf` cases to PASS while the sensitive `wip` case remains red.

### Task 3: Add the sensitive-path guard to `wip`

**Files:**
- Modify: `stow/bash/.bash_lib/git.sh`

- [x] **Step 1: Add the pathname predicate**

Add before `wip`:

```bash
_git_has_sensitive_staged_paths() {
  git diff --cached --name-only -z |
    grep -zEq '(^|/)(\.env($|\.)|.*\.(pem|key|p12|pfx|kdbx)$|.*(secret|credential|token|password).*)'
}
```

It must consume only NUL-delimited pathnames and return success when a pathname matches.

- [x] **Step 2: Guard after staging**

Immediately after `git add -A`, add:

```bash
if _git_has_sensitive_staged_paths; then
  printf 'WIP abortado: hay rutas sensibles staged. Revisa `git diff --cached --name-only`.\n' >&2
  return 1
fi
```

Do not print contents and do not automatically unstage anything.

- [x] **Step 3: Run the focused test**

Run `bash tests/bash_git_safety_test.sh`; expect all cases to PASS.

### Task 4: Verify compatibility and commit

**Files:**
- Modify: `tests/bash_git_safety_test.sh`
- Modify: `stow/bash/.bash_aliases`
- Modify: `stow/bash/.bash_lib/git.sh`

- [x] **Step 1: Verify runtime types**

Source `.bashrc` in a clean shell and print only `type -t gpf`, `type -t gp`, `type -t gundo`, and `type -t gclean`. Expected: `function` for all four.

- [x] **Step 2: Run full tests and syntax checks**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh; do bash -n "$file"; done
git diff --check
```

Expected: every test exits 0, every Bash file parses, and the diff has no whitespace errors.

- [x] **Step 3: Inspect scope and secrets**

Run `git diff -- stow/bash/.bash_aliases stow/bash/.bash_lib/git.sh tests/bash_git_safety_test.sh`. Confirm no tmux/i3 files, local override files, secret values, or unrelated commands changed.

- [x] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bash_aliases stow/bash/.bash_lib/git.sh tests/bash_git_safety_test.sh
git commit -m "feat(bash): protect risky Git shortcuts"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
