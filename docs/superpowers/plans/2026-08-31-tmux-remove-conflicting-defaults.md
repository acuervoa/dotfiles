# Remove Conflicting tmux Defaults Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task with review checkpoints.

**Goal:** Remove only the four tmux prefix bindings that compete with the canonical one-key grammar.

**Architecture:** Add explicit `unbind` commands after plugin initialization and custom bindings so the final key table is authoritative. Update user-facing and generated documentation to describe the canonical routes and omit the removed aliases. Validate with an isolated tmux server before reloading the active server.

**Tech Stack:** tmux 3.7c, Bash, Markdown.

---

### Task 1: Remove the four conflicting bindings

**Files:**
- Modify: `stow/tmux/.tmux.conf` near the final productivity bindings.

- [x] **Step 1: Add explicit unbinds after custom bindings.**

Add this block after the final custom pane/window bindings and before the help popup:

```tmux
# Eliminar aliases legacy que compiten con la gramática principal.
unbind '"'
unbind %
unbind Space
unbind Z
```

- [x] **Step 2: Confirm the canonical bindings remain unchanged.**

The final prefix table must still contain:

```text
d  split-window -v
r  split-window -h
p  display-panes
z  resize-pane -Z
```

- [x] **Step 3: Commit the configuration change.**

```bash
git add stow/tmux/.tmux.conf
git commit -m "refactor(tmux): remove conflicting legacy bindings"
```

### Task 2: Align documentation

**Files:**
- Modify: `tmux-cheatsheet.md`
- Modify: `keymap-maestro.md`
- Modify: `SHORTCUTS.md`
- Modify: `scripts/generate_shortcuts_doc.sh`

- [x] **Step 1: Remove legacy aliases from primary documentation.**

Do not list `Prefix+"`, `Prefix+%`, `Prefix+Space`, or `Prefix+Z` as available shortcuts. Keep the canonical `d`, `r`, `p`, and `z` entries.

- [x] **Step 2: Keep secondary non-conflicting shortcuts documented separately.**

Do not remove `w`, `D`, `(`, `)`, `Tab`, `o`, or other non-conflicting tmux defaults.

- [x] **Step 3: Commit documentation changes.**

```bash
git add tmux-cheatsheet.md keymap-maestro.md SHORTCUTS.md scripts/generate_shortcuts_doc.sh
git commit -m "docs(tmux): remove retired shortcut aliases"
```

### Task 3: Verify before activation

**Files:**
- Read-only validation of `stow/tmux/.tmux.conf` and the active runtime.

- [x] **Step 1: Start an isolated tmux server.**

```bash
tmux -L tmux-conflict-check -f /home/acuervo/dotfiles/stow/tmux/.tmux.conf new-session -d -s verify -c /home/acuervo/dotfiles
```

- [x] **Step 2: Verify removed and canonical bindings.**

```bash
tmux -L tmux-conflict-check list-keys -T prefix
```

Expected: no `"`, `%`, `Space`, or `Z` bindings; `d`, `r`, `p`, and `z` retain their canonical actions.

- [x] **Step 3: Stop only the isolated server.**

```bash
tmux -L tmux-conflict-check kill-server
```

- [x] **Step 4: Reload the active server after verification.**

```bash
tmux source-file /home/acuervo/.tmux.conf
```

- [x] **Step 5: Confirm the active prefix table and clean diff.**

```bash
tmux list-keys -T prefix
git diff --check
git status --short
```

Expected: the four conflicts are absent, canonical bindings are present, and unrelated pre-existing changes remain unstaged.
