# Bash Interactive Keymap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Give Bash one idempotent owner for interactive keys, preserve tmux's `Ctrl-s`, and add FZF file/directory selectors on `Ctrl-t` and `Alt-c`.

**Architecture:** A new `stow/bash/.bash_lib/keymap.sh` owns Readline and ble.sh bindings. `.bashrc` initializes integrations first, then sources this module, then attaches ble. Existing `fhist`, `fo`, and `cdf` functions are reused; no selector implementation is duplicated.

**Tech Stack:** Bash, Readline `bind`, ble.sh `ble-bind`, Atuin, existing FZF-backed functions.

---

### Task 1: Add red keymap tests

**Files:**
- Create: `tests/bash_keymap_test.sh`
- Reference: `stow/bash/.bashrc`
- Reference: `stow/bash/.bash_lib/keymap.sh`

- [ ] **Step 1: Test Readline owner contract**

In a clean Bash shell, source the versioned library and keymap module, then inspect `bind -S`. Assert that `Ctrl-r` has one configured binding, `Ctrl-t` is bound through `shell-command`/`bind -x` to the file selector, `Alt-c` is bound to the directory selector, and `Ctrl-s` is not introduced by the keymap module.

- [ ] **Step 2: Test reload idempotence**

Source the keymap module twice and compare the complete filtered `bind -S` output for `Ctrl-r`, `Ctrl-t`, `Alt-c`, Tab, and Shift-Tab. The snapshots must be identical.

- [ ] **Step 3: Test missing optional tools**

Run the module in a temporary `PATH` containing Bash and basic coreutils but no FZF/zoxide. Sourcing must exit successfully; invoking the wrappers must return a diagnostic without breaking the shell.

- [ ] **Step 4: Run the test before implementation**

Run `bash tests/bash_keymap_test.sh`. Expected: FAIL because the module does not exist and `Ctrl-t`/`Alt-c` have no owner.

### Task 2: Create the explicit keymap module

**Files:**
- Create: `stow/bash/.bash_lib/keymap.sh`

- [ ] **Step 1: Define guarded Readline wrappers**

Add private wrappers that call `fhist`, `fo`, and `cdf` only when the functions exist; otherwise print a concise diagnostic and return 1. Do not call FZF directly from the key bindings.

- [ ] **Step 2: Define Readline bindings**

When `bind` is available, bind `Ctrl-r` to Atuin's `__atuin_history` if that function exists, otherwise to the history wrapper. Bind `Ctrl-t` to the file wrapper and `Alt-c` (`\e\C-c`) to the directory wrapper. Preserve menu completion on Tab and Shift-Tab. Do not bind `Ctrl-s`.

- [ ] **Step 3: Define ble bindings**

When `BLE_VERSION` and `ble-bind` are available, assign `C-r` to Atuin or fallback history, `C-t` to the file wrapper, and `M-c` to the directory wrapper. Do not bind `C-s`.

- [ ] **Step 4: Validate the focused test**

Run `bash tests/bash_keymap_test.sh`; expected: all Readline, reload, and optional-tool cases PASS. The ble assertions may be skipped when the test shell has no TTY, but the module must remain syntactically valid.

### Task 3: Make `.bashrc` load the module once in the correct order

**Files:**
- Modify: `stow/bash/.bashrc`

- [ ] **Step 1: Remove inline key ownership**

Remove the existing Readline completion `bind` block and the inline Atuin/ble `Ctrl-r` binding case. Keep Atuin initialization, `HIST_BACKEND`, and `ble-attach` in their current lifecycle positions.

- [ ] **Step 2: Source `keymap.sh` after integrations**

Source `$HOME/.bash_lib/keymap.sh` after Atuin initialization and before `ble-attach`, so the module sees Atuin and can configure both key systems. The source must be conditional on the file being readable.

- [ ] **Step 3: Preserve startup behavior**

Ensure `.bashrc` still loads without FZF, Atuin, or ble.sh and that no `Ctrl-s` binding is added. Run `bash -n stow/bash/.bashrc stow/bash/.bash_lib/keymap.sh`.

### Task 4: Verify runtime, docs, and compatibility

**Files:**
- Modify: `tests/bash_keymap_test.sh`
- Modify: `stow/bash/.bashrc`
- Create: `stow/bash/.bash_lib/keymap.sh`

- [ ] **Step 1: Verify effective Readline bindings**

Source the real `.bashrc` in a clean shell and print only filtered `bind -S` entries for `Ctrl-r`, `Ctrl-t`, `Alt-c`, Tab, Shift-Tab, and `Ctrl-s`. Expected: the three intended owners exist, completion remains configured, and no keymap code assigns `Ctrl-s`.

- [ ] **Step 2: Run the complete Bash suite and syntax checks**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh scripts/generate_bash_shortcuts.sh; do bash -n "$file"; done
git diff --check
```

Expected: every test exits 0, every Bash file parses, and no whitespace errors are reported.

- [ ] **Step 3: Check scope and tmux safety**

Run `git diff -- stow/bash/.bashrc stow/bash/.bash_lib/keymap.sh tests/bash_keymap_test.sh`. Confirm no tmux/i3 files, prefix changes, `.bashrc_local`, or secret values changed; confirm `Ctrl-s` is absent from added binding commands.

- [ ] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bashrc stow/bash/.bash_lib/keymap.sh tests/bash_keymap_test.sh
git commit -m "feat(bash): centralize interactive keymap"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
