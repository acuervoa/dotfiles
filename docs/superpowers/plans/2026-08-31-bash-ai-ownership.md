# Bash AI Grammar Ownership Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Consolidate the versioned Bash AI commands in `ai.sh`, remove duplicate definitions from `.bashrc`, and prove reload stability without touching local secrets.

**Architecture:** `stow/bash/.bash_lib/ai.sh` owns the public AI grammar. `.bashrc` only loads the library and local overrides; `~/.bashrc_local` remains an explicit user-owned override outside the repository. A shell test checks static ownership and runtime type/name stability.

**Tech Stack:** Bash, ripgrep, sha256sum, GNU coreutils.

---

### Task 1: Add regression tests for AI ownership

**Files:**
- Create: `tests/bash_ai_ownership_test.sh`
- Reference: `stow/bash/.bash_lib/ai.sh`
- Reference: `stow/bash/.bashrc`

- [ ] **Step 1: Write the static ownership test**

Create a shell test with `set -u`, `repo_root`, `fail()` and `pass()` helpers, then define:

```bash
expected=(afs afc afd afa af afl afx aflastdraft afapplylast afdp afdb sbclose ai)
```

For each name, assert exactly one declaration in `ai.sh` and no declaration in `.bashrc`. Also assert `.bashrc` contains neither AgentMemory autostart nor secret-like variables.

- [ ] **Step 2: Add the reload contract test**

Create a temporary `HOME`, copy `.bashrc`, `.bash_aliases`, `.bash_functions`, `.profile`, and `.bash_lib/*.sh`, and create a synthetic empty `.bashrc_local`. In a clean Bash shell, source `.profile` and `.bashrc`, record `type -t` for every expected AI name, source `.bashrc` twice, and assert the result is unchanged. Expected types are aliases for `afs`, `afc`, `afd`, `afa`, and functions for every remaining name. The test must never print the real `~/.bashrc_local`.

- [ ] **Step 3: Run the test before implementation**

Run `bash tests/bash_ai_ownership_test.sh`. Expected: FAIL at the ownership assertions because the current layout still duplicates or lacks owners.

### Task 2: Consolidate public definitions in `ai.sh`

**Files:**
- Modify: `stow/bash/.bash_lib/ai.sh`

- [ ] **Step 1: Move the `.bashrc`-only functions**

Add `af`, `afl`, `afx`, `afdp`, and `afdb` to `ai.sh`, preserving the current interfaces:

```bash
af() { ai-flow start --task "$*"; }
afl() { ai-flow start --task "$*" --launch; }
afx() {
  local task="$1"
  local done_msg="${2:-Cierre rápido}"
  local next_msg="${3:-Revisar draft}"
  ai-flow cycle --task "$task" --done "$done_msg" --next "$next_msg"
}
afdp() {
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  bash "$_sb_vault/tools/ai-distill-pipeline.sh" "$@"
}
afdb() {
  local _sb_vault="${SIMPLEBRAIN_VAULT:-$HOME/Vaults/SimpleBrain}"
  python3 "$_sb_vault/tools/distill_bulk.py" "$@"
}
```

- [ ] **Step 2: Add discoverability annotations**

Place `# @cmd` comments immediately above the moved functions: `af` starts AI Flow, `afl` starts and launches, `afx` runs a cycle, `afdp` runs distillation, and `afdb` processes pending historical sessions.

- [ ] **Step 3: Validate syntax**

Run `bash -n stow/bash/.bash_lib/ai.sh`; expect exit 0 with no output.

### Task 3: Remove duplicate AI definitions from `.bashrc`

**Files:**
- Modify: `stow/bash/.bashrc`

- [ ] **Step 1: Delete only the AI block**

Remove the block beginning `# --- AI Flow shortcuts ---` after the `.bashrc_local` source and ending `# --- /AI Flow shortcuts ---`. Keep the `.bashrc_local` source, OpenClaw completion, Juliaup completion, and PATH normalization unchanged.

- [ ] **Step 2: Run ownership checks**

Run `bash tests/bash_ai_ownership_test.sh`. Expected: all static and reload checks PASS, with no output from local override contents.

### Task 4: Full verification and commit

**Files:**
- Modify: `tests/bash_ai_ownership_test.sh`
- Modify: `stow/bash/.bashrc`
- Modify: `stow/bash/.bash_lib/ai.sh`

- [ ] **Step 1: Run all Bash tests**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
```

Expected: every test exits 0 and reports PASS.

- [ ] **Step 2: Verify the real runtime without printing local values**

Run a clean interactive Bash that sources `/home/acuervo/.bashrc` with output redirected, then prints only `name=type` from `type -t` for the expected names. Expected: four aliases and nine functions.

- [ ] **Step 3: Inspect scope and whitespace**

Run:

```bash
git diff --check
git diff -- stow/bash/.bashrc stow/bash/.bash_lib/ai.sh tests/bash_ai_ownership_test.sh
```

Expected: no whitespace errors, no tmux/i3 changes, no local override file, and no secret values.

- [ ] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bashrc stow/bash/.bash_lib/ai.sh tests/bash_ai_ownership_test.sh
git commit -m "refactor(bash): centralize AI command ownership"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
