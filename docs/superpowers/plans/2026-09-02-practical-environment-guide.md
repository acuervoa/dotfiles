# Practical Environment Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a progressive, self-contained daily-use guide for the coordinated Kitty, i3, tmux, Bash, Neovim and project workflow.

**Architecture:** Add one user-facing Markdown guide under `docs/`, organized by complete workflows rather than by application. Add a static Bash contract test for required sections, commands and references. Do not alter configuration.

**Tech Stack:** Markdown, Bash contract test, existing shell validation scripts.

---

### Task 1: Add the guide coverage contract

**Files:**
- Create: `tests/practical_environment_guide_test.sh`

- [ ] **Step 1: Write the failing test**

Create a Bash test that resolves the repository root, requires
`docs/practical-environment-guide.md`, checks headings `Modelo mental`,
`Arranque`, `Workflow backend`, `Git`, `Logs`, `Cierre y recuperación` and
`Ejercicios`, and verifies mentions of `C-s`, `$mod`, `tproj`, `<leader>pt`,
`lg`, `dlogs`, `clipmenu`, `Atuin`, `Rofi` and `Yazi`. Also require links to
`SHORTCUTS.md`, `stow/nvim/.config/nvim/USAGE.md`,
`docs/audits/2026-09-01-neovim-workflows.md` and
`docs/audits/2026-09-02-application-integration.md`.

- [ ] **Step 2: Verify red**

Run `bash tests/practical_environment_guide_test.sh`.
Expected: FAIL because the guide does not exist.

- [ ] **Step 3: Commit**

Run `chmod +x tests/practical_environment_guide_test.sh`, then commit the
test as `test(docs): define practical environment guide coverage`.

### Task 2: Write the progressive guide

**Files:**
- Create: `docs/practical-environment-guide.md`

- [ ] **Step 1: Orientation and startup**

Document ownership in plain language and the sequence
`i3 $mod+Return → Kitty → tmux (prefix C-s)`. Cover `$mod+d` applications,
`$mod+f` windows, `$mod+v` clipboard history, `$mod+y` notifications and
`C-s ?` help. Explain Kitty as transport, tmux as pane/window/session owner,
and `Escape` as selector cancellation.

- [ ] **Step 2: Project and editor workflow**

Document `tproj <nombre>` and `dev`, including the expected editor, shell and
logs layout. Give the sequence `<C-p>`/`<leader>ff`, `<leader>fg`,
`C-h/j/k/l`, `<leader>pt`, `<leader>pT`, `<leader>pf`, `<leader>pl` and
`<leader>po`, with expected results. State that `<leader>` is Space and
`p/r/y/n/z` retain native Vim meaning while Bash provides contextual commands.

- [ ] **Step 3: History, clipboard and selectors**

Explain `C-r` for Atuin, FZF as reusable selector, Rofi for visual selection,
clipmenu as clipboard-history owner, Kitty `Ctrl+Shift+C/V` and Bash `cb` as
transport. Include cancellation and state that these components do not replace
one another.

- [ ] **Step 4: Git, logs, monitoring and closure**

Document `lg`, `C-s g` and `<leader>gg` as equivalent LazyGit entrypoints;
`dlogs`/`lnav` for logs; `C-s b`/`btop` for monitoring; and the project shell
for Docker. Include safe closure with `C-s q`, Neovim `<leader>q`, `Escape`
and i3 `$mod+q` confirmation.

- [ ] **Step 5: Exercises and fallbacks**

Provide three exercises: open/edit/test; inspect Git and return; inspect
logs/resources and close temporary views. Each needs start state, numbered
sequence and expected end state. Add fallbacks for missing FZF, Docker,
LazyGit, Yazi, lnav and btop. Do not suggest configuration changes or
destructive operations.

- [ ] **Step 6: References and contract**

Link root `SHORTCUTS.md`, Neovim `SHORTCUTS.md`/`USAGE.md`,
`docs/audits/2026-09-01-neovim-workflows.md`,
`docs/audits/2026-09-02-application-integration.md`,
`docs/bash-workflows.md` and `docs/bash-muscle-memory.md`. Run
`bash tests/practical_environment_guide_test.sh`; expected PASS without
starting applications or reading private clipboard/history. Commit as
`docs(productivity): add practical environment guide`.

### Task 3: Validate and hand off

**Files:**
- Inspect: `docs/practical-environment-guide.md`
- Inspect: `tests/practical_environment_guide_test.sh`

- [ ] **Step 1: Run checks**

Run `bash tests/practical_environment_guide_test.sh`,
`bash tests/application_release_gate_test.sh`, `bash scripts/check.sh` and
`git diff --check`. Expected: all pass and generated shortcuts leave the tree
clean.

- [ ] **Step 2: Verify protected scope**

Run `git diff --name-only 974a4ec...HEAD -- stow/tmux/.tmux.conf stow/i3/.config/i3/config`.
Expected: no output. Do not read or modify `~/.bashrc_local`.

- [ ] **Step 3: Correct only if required**

If validation finds an issue, make the smallest correction, rerun all checks
and commit it as `fix(docs): align practical guide validation`; otherwise leave
the clean checkout unchanged.
