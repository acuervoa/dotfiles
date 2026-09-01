# Bash Operational Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Document a context-first grammar for the existing Bash, tmux and i3 workflows without changing commands, aliases or bindings.

**Architecture:** Keep `BASH_SHORTCUTS.md` as the generated catalog. Add focused documents for workflows, cross-context key ownership and memory-muscle drills. Use current dotfiles and tests as the source of truth.

**Tech Stack:** Markdown, Bash, `rg`, existing Bash tests, `git diff --check`.

---

## File map

- Create `docs/bash-workflows.md`: backend PHP, servers, Git, Docker and AI sequences.
- Create `docs/bash-context-key-matrix.md`: Bash/Readline/ble.sh/tmux/i3 ownership.
- Create `docs/bash-muscle-memory.md`: six micro-command drills and friction log.
- Do not modify `stow/bash`, `stow/tmux`, `stow/i3`, `.bashrc_local` or runtime configuration.

### Task 1: Context workflow guide

**Files:** Create `docs/bash-workflows.md`; reference `.bash_grammar`, the command audit and the performance baseline.

- [ ] **Step 1: Create the sections**

Create Spanish Markdown sections: `Regla de lectura`, `Backend PHP`, `Servidores`, `Git`, `Docker`, `AI y SimpleBrain`, `Salidas seguras y validación` and `Referencias`.

Add a quick-index table mapping `g*` to Git, `d*` to Docker, `p*` to
PHP/Laravel, `r*` to runtime/QA/servers, `af*` to AI Flow and `sb*` to
SimpleBrain; identify unprefixed navigation, system, utility and
micro-commands separately.

- [ ] **Step 2: Document approved sequences**

Preserve these exact sequences: `proj/tproj → gs → dcu/dev → p/part/ptest → qa`; `ports → rserve → dlogs/topme → rqa/rtest`; `gs → gd/gds → ga → gcm/wip → gp`; `docps/dps → dlogs/dsh → dcu/dcud → dcrb/dorebuild → dclean`; `sbs/af → afl (optional) → sbsb/sbo → sbe/afx → aflastdraft/afapplylast`. For every step state purpose, mutation scope and validation command. Mark `gclean`, `gundo`, `gpf`, `dclean`, `dcrb`, `dorebuild`, `pmig`, `pseed` and `pclear` as confirmation-sensitive.

- [ ] **Step 3: Add safe exits and references**

Document cancelling selectors, rejecting confirmations, inspecting `gs`/`docps` before mutation and using `rtest`/`qa`/`rqa` for validation. Link `BASH_SHORTCUTS.md`, the audit, the baseline and the design spec.

Add a compatibility note for `pbcopy`/`pbpaste` and a dependency note for
the dynamic `z` function supplied by `zoxide init bash`; neither should be
renamed or reimplemented.

- [ ] **Step 4: Validate and commit**

Run `rg -n 'proj|tproj|ports|rserve|gs|gd|gds|ga|gcm|wip|gp|docps|dps|dlogs|dsh|dcu|dcud|dcrb|dorebuild|dclean|sbs|af|afl|sbsb|sbo|sbe|afx|aflastdraft|afapplylast' docs/bash-workflows.md` and `git diff --check`; expect all sequence commands and exit 0. Commit with `git add docs/bash-workflows.md && git commit -m "docs(bash): add context workflows"`.

### Task 2: Cross-context key matrix

**Files:** Create `docs/bash-context-key-matrix.md`; reference `stow/bash/.bash_lib/keymap.sh`, `stow/tmux/.tmux.conf`, `stow/i3/.config/i3/config` and the command audit.

- [ ] **Step 1: Add effective ownership**

Document: Bash `l,n,p,r,y,z`; Readline/ble.sh `C-r,C-t,M-c,Tab,Shift-Tab`, with `C-s` free; tmux prefix `C-s`, `p,r,n,q,z` after prefix and `y` in `copy-mode-vi`; i3 `Mod4+r`, `Mod4+q`, `Mod4+y`, `Mod4+z`, `Mod4+Shift+n`.

- [ ] **Step 2: Explain layer separation**

State that repeated letters are not silent collisions because layers and modifiers differ. Explicitly explain Bash `r` versus tmux `C-s r`/i3 `Mod4+r`, and Bash `p` versus tmux `C-s p`.

- [ ] **Step 3: Add checks and commit**

Document read-only checks `bind -X`, `bind -q menu-complete`, `bind -q menu-complete-backward`, `tmux show-options -gqv prefix`, `tmux list-keys -T prefix` and `i3-msg -t get_config`. State invariants: tmux prefix `C-s`, Bash does not bind `C-s`, and no configuration change is implied. Run `rg -n 'C-s|C-r|C-t|M-c|Mod4\\+r|Mod4\\+q|Mod4\\+y|Mod4\\+z|copy-mode-vi' docs/bash-context-key-matrix.md`, `git diff --check`, then commit with `git add docs/bash-context-key-matrix.md && git commit -m "docs(bash): map cross-context key ownership"`.

### Task 3: Memory-muscle drills

**Files:** Create `docs/bash-muscle-memory.md`; reference `.bash_grammar`, `BASH_SHORTCUTS.md` and `docs/bash-workflows.md`.

- [ ] **Step 1: Add micro-command drills**

Create a table for `l`, `n`, `p`, `r`, `y` and `z` with action, safe practice invocation, dependency/precondition and verification. Do not invent replacement names.

- [ ] **Step 2: Add workflow drills**

Add one exercise per workflow. Each starts with inspection and ends with validation; mutation exercises explicitly instruct the user to reject confirmation during the first pass.

- [ ] **Step 3: Add friction log**

Include fields: Fecha, Contexto (`Bash / tmux / i3 / Readline`), Secuencia intentada, Comando o tecla dudosa, Resultado observado, confirmación/rollback and Acción propuesta (`observar / documentar / cambiar en fase posterior`). State that one observation cannot retire a command; a second audit after real use is required.

- [ ] **Step 4: Validate and commit**

Run `rg -n '^\`(l|n|p|r|y|z)\`|Registro de fricción|cancel|confirmación|rollback' docs/bash-muscle-memory.md` and `git diff --check`; then commit with `git add docs/bash-muscle-memory.md && git commit -m "docs(bash): add memory muscle drills"`.

### Task 4: Cross-document validation

**Files:** Verify the three new documents, `BASH_SHORTCUTS.md`, `.bash_grammar`, `.bashrc`, `.tmux.conf` and i3 config.

- [ ] **Step 1: Verify references**

Run `for command in l n p r y z; do rg -n "\\\`$command\\\`" docs/bash-workflows.md docs/bash-muscle-memory.md BASH_SHORTCUTS.md; done` and `rg -n 'C-s|tmux|Mod4|Readline|ble.sh' docs/bash-workflows.md docs/bash-context-key-matrix.md`. Expect all six micro-commands and cross-context references to resolve.

- [ ] **Step 2: Run the existing suite**

Run `for test in tests/bash_*_test.sh; do bash "$test"; done`, run `bash -n` for `stow/bash/.bashrc`, `.bash_profile`, `.profile`, `.bash_aliases`, `.bash_functions` and `stow/bash/.bash_lib/*.sh`, then run `git diff --check`. Expect every test and syntax check to pass.

- [ ] **Step 3: Verify protected scope**

Run `git diff --name-only HEAD~3..HEAD -- stow/bash stow/tmux stow/i3 .bashrc_local` and `git status -sb`. Expect no protected paths and a clean worktree after the three documentation commits.

- [ ] **Step 4: Handoff**

Report the three documents and explicitly state that no command, alias, binding, PATH rule or runtime behavior changed. The next phase is Kitty + i3 + tmux first-order latency measurement before any performance optimization.
