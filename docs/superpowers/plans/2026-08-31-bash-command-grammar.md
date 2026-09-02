# Bash Command Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Document and validate the existing Bash command grammar by family, risk, and micro-shortcut status without renaming or adding commands.

**Architecture:** A versioned TSV catalog is the metadata source for public commands. A deterministic generator produces `BASH_SHORTCUTS.md`; `dothelp` consumes the same catalog when available and falls back to its current function annotations. A linter compares catalog names with public versioned definitions and checks the fixed one-key set.

**Tech Stack:** Bash, awk, ripgrep, GNU coreutils, Markdown.

---

### Task 1: Add the catalog and red validation test

**Files:**
- Create: `stow/bash/.bash_grammar`
- Create: `tests/bash_grammar_test.sh`

- [x] **Step 1: Define the catalog format**

Create a tab-separated file with this header:

```text
name	group	risk	micro	description	example
```

Use one row per public alias/function. Groups are `git`, `docker`, `php`, `runtime`, `ai`, `simplebrain`, `navigation`, `system`, or `utility`; risk is `safe`, `confirm`, or `mutating`; micro is `yes` or `no`. Do not include values, paths containing user data, or command arguments that could expose secrets.

- [x] **Step 2: Populate the initial catalog**

Record all current public names from `.bash_aliases`, `ai.sh`, and the `# @cmd` functions. Mark `l`, `n`, `p`, `r`, `y`, and `z` as micro shortcuts. Mark `gpf`, `gundo`, `gclean`, `wip`, `pmig`, `pseed`, `pclear`, `dorebuild`, `dcrb`, `dclean`, and `envswap` as `confirm`; mark read-only/query commands as `safe`.

- [x] **Step 3: Write the failing linter test**

Create a test that extracts public alias/function names from the versioned Bash files, ignores private names beginning with `_`, compares the set with the catalog, rejects duplicate catalog rows, validates group/risk/micro values, and asserts the exact micro set `l n p r y z`.

- [x] **Step 4: Run the red test**

Run `bash tests/bash_grammar_test.sh`. Expected: FAIL until the catalog contains every public command and its metadata is valid.

### Task 2: Build the deterministic Bash cheatsheet generator

**Files:**
- Create: `scripts/generate_bash_shortcuts.sh`
- Create: `BASH_SHORTCUTS.md`

- [x] **Step 1: Implement catalog parsing**

Write a strict Bash generator using `set -euo pipefail`, resolving the repository root from `BASH_SOURCE`, reading `stow/bash/.bash_grammar`, rejecting malformed rows, and sorting rows by group then name. It must write through a temporary file and replace `BASH_SHORTCUTS.md` only after successful generation.

- [x] **Step 2: Generate the document structure**

Generate Spanish sections for: `Micro-atajos`, `Git`, `Docker`, `PHP/Laravel`, `Runtime/QA`, `AI Flow`, `SimpleBrain`, and `Navegación/Sistema/Utilidad`. Each row must contain command, description, risk, and example. Render `confirm` as `⚠️ confirmación`, `mutating` as `🔴 mutación`, and `safe` as `✅ seguro`.

- [x] **Step 3: Add reproducibility checks**

Run the generator twice and assert the second run produces no diff. The generator must not include `$HOME`, `.bashrc_local`, environment values, or secret-like patterns in the output.

- [x] **Step 4: Run the generator**

Run `bash scripts/generate_bash_shortcuts.sh`; expected: `BASH_SHORTCUTS.md` is generated deterministically.

### Task 3: Integrate catalog metadata into `dothelp`

**Files:**
- Modify: `stow/bash/.bash_lib/core.sh`
- Modify: `stow/bash/.bashrc`

- [x] **Step 1: Add a catalog resolver**

In `core.sh`, resolve `${BASH_GRAMMAR_FILE:-$HOME/.bash_grammar}` and validate that it is readable before using it. Never source the file; parse it as data only.

- [x] **Step 2: Extend `dothelp`**

When the catalog exists, make `dothelp` render grouped entries with risk markers and descriptions from the catalog, including aliases and AI/SimpleBrain commands. Preserve the current annotation-based fallback when the catalog is absent.

- [x] **Step 3: Keep runtime loading cheap and idempotent**

Do not parse the catalog during every Bash startup. Load it only when `dothelp` or `blib-help` is invoked, and ensure two consecutive invocations produce the same output.

- [x] **Step 4: Add the catalog path to the Bash installation contract**

Ensure the stow layout places `.bash_grammar` beside `.bashrc` and `.bash_lib`, without modifying `.bashrc_local`.

### Task 4: Verify grammar, docs, and compatibility

**Files:**
- Modify: `tests/bash_grammar_test.sh`
- Modify: `stow/bash/.bash_grammar`
- Modify: `scripts/generate_bash_shortcuts.sh`
- Modify: `BASH_SHORTCUTS.md`
- Modify: `stow/bash/.bash_lib/core.sh`
- Modify: `stow/bash/.bashrc`

- [x] **Step 1: Run grammar and generator tests**

Run:

```bash
bash tests/bash_grammar_test.sh
bash scripts/generate_bash_shortcuts.sh
git diff --exit-code -- BASH_SHORTCUTS.md
```

Expected: the linter passes, generation succeeds, and a second generation is idempotent.

- [x] **Step 2: Run the complete Bash suite and syntax checks**

Run:

```bash
for test in tests/bash_*_test.sh tests/agentmemory_service_test.sh; do bash "$test"; done
for file in stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh scripts/generate_bash_shortcuts.sh; do bash -n "$file"; done
git diff --check
```

Expected: every test exits 0, every Bash file parses, and no whitespace errors are reported.

- [x] **Step 3: Verify runtime and scope**

Source `.bashrc` in a clean shell and print only the types of `l`, `n`, `p`, `r`, `y`, `z`, `dothelp`, and `blib-help`. Run `dothelp` twice and compare output. Confirm no tmux/i3 files, `.bashrc_local`, environment values, or secrets changed.

- [x] **Step 4: Commit**

Run:

```bash
git add stow/bash/.bash_grammar tests/bash_grammar_test.sh scripts/generate_bash_shortcuts.sh BASH_SHORTCUTS.md stow/bash/.bash_lib/core.sh stow/bash/.bashrc
git commit -m "docs(bash): codify command grammar"
```

Expected: the global pre-commit hook passes and one implementation commit is created.
