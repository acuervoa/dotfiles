# tmux Key Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (recommended) to implement this plan task-by-task with review checkpoints.

**Goal:** Activate and document a one-keystroke-after-`C-s` tmux grammar optimized for a Spanish keyboard, while preserving rollback and Vim/i3 integration.

**Architecture:** Modify only the stowed tmux configuration and its cheatsheet. Validate the configuration through an isolated tmux server/socket, then smoke-test the key table and critical plugin integrations before reloading the user's active server.

**Tech Stack:** tmux 3.7c, Bash, tmux-resurrect, tmux-sessionx, tmux-fzf, extrakto, git.

---

## File map

- Modify `stow/tmux/.tmux.conf`: canonical bindings and resurrect mapping.
- Modify `tmux-cheatsheet.md`: user-facing muscle-memory reference.
- Do not modify the pre-existing dirty files shown by `git status`.
- Rollback source: `/home/acuervo/backups/tmux-audit-20260830-203649`.

### Task 1: Add the direct one-key grammar

**Files:**
- Modify: `stow/tmux/.tmux.conf` in the navigation, split, window, session, popup, and reload binding sections.

- [ ] **Step 1: Preserve existing Vim-aware navigation.**

Keep the no-prefix `C-h/j/k/l` bindings and the prefix `h/j/k/l` bindings. Keep `H/J/K/L` as prefix resize bindings, replacing the current no-prefix Alt-Shift arrows only if the verification confirms the new chords work on the Spanish keyboard.

- [ ] **Step 2: Replace the reload conflict with directional splits.**

Change the existing split/reload bindings to this canonical block:

```tmux
unbind r
bind d split-window -v -c "#{pane_current_path}"
bind r split-window -h -c "#{pane_current_path}"
bind R source-file ~/.tmux.conf \; display "🔄 Config reloaded!"
```

`d` means down, `r` means right, and uppercase `R` means reload.

- [ ] **Step 3: Make the remaining core actions explicit.**

Ensure the canonical prefix bindings are present and point to the existing commands:

```tmux
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind H resize-pane -L 5
bind J resize-pane -D 2
bind K resize-pane -U 2
bind L resize-pane -R 5
bind z resize-pane -Z \; display-message "🔎 Zoom: #{window_zoomed_flag}"
bind q kill-pane
bind p display-panes
bind ! run-shell 'cmd=$(tmux display-message -p "#{pane_current_command}"); dir=$(tmux display-message -p "#{b:pane_current_path}"); tmux break-pane -d -n "${cmd} — ${dir##*/}"'
bind c new-window -c "#{pane_current_path}"
bind n next-window
bind N previous-window
bind a last-window
bind , command-prompt -I "#W" 'rename-window "%%"'
bind s choose-tree -sw
bind S if-shell 'test -x "#{env:TMUX_PLUGIN_MANAGER_PATH}tmux-sessionx/scripts/sessionx.sh"' 'run-shell -b "#{env:TMUX_PLUGIN_MANAGER_PATH}tmux-sessionx/scripts/sessionx.sh"' 'choose-tree -sw'
bind g display-popup -E -w 90% -h 90% -x C -y C "lazygit"
bind b display-popup -E -w 90% -h 90% -x C -y C "btop"
bind x run-shell -b "extrakto"
bind A run-shell -b "$HOME/.tmux/scripts/agent_room.sh"
bind m run-shell -b "#{env:TMUX_PLUGIN_MANAGER_PATH}tmux-menus/scripts/menu.sh"
```

Before adding `A`, verify whether an agent-room script already exists. If it does not, bind `A` to the existing project/session picker temporarily and record that the dedicated agent launcher is a follow-up scope; do not invent an agent workflow in this task.

- [ ] **Step 4: Configure restore as uppercase `U`.**

Set the resurrect restore key to `U` while retaining `M-r` as a compatibility alias until the new grammar is proven:

```tmux
set -g @resurrect-restore 'U'
bind U run-shell -b "#{env:TMUX_PLUGIN_MANAGER_PATH}tmux-resurrect/scripts/restore.sh"
bind M-r run-shell -b "#{env:TMUX_PLUGIN_MANAGER_PATH}tmux-resurrect/scripts/restore.sh"
```

- [ ] **Step 5: Keep destructive actions protected.**

If the current `q` binding has no confirmation, add a tmux confirmation prompt before `kill-pane`; retain `BSpace` as an explicit legacy bulk-close action during transition.

- [ ] **Step 6: Commit only the tmux configuration.**

Run:

```bash
git -C /home/acuervo/dotfiles add stow/tmux/.tmux.conf
git -C /home/acuervo/dotfiles commit -m "feat(tmux): adopt one-key command grammar"
```

Expected: one commit containing only `stow/tmux/.tmux.conf`.

### Task 2: Update the cheatsheet as training material

**Files:**
- Modify: `tmux-cheatsheet.md`.

- [ ] **Step 1: Replace the old split/reload entries.**

Document `d`, `r`, `R`, and `U` as the canonical paths. Remove `"` and `%` from the primary table, or label them explicitly as tmux legacy aliases.

- [ ] **Step 2: Remove competing primary paths.**

Mark `Tab`, `o`, `M-Left/Right`, and `C-PageUp/Down` as compatibility alternatives, not the recommended training path.

- [ ] **Step 3: Add the grammar rules at the top.**

Include this compact rule:

```markdown
> Núcleo: `C-s` + una tecla = una acción. `h/j/k/l` mueve; `H/J/K/L` redimensiona.
> Las letras mayúsculas y los símbolos se usan solo cuando aportan una distinción clara.
```

- [ ] **Step 4: Commit the documentation separately.**

Run:

```bash
git -C /home/acuervo/dotfiles add tmux-cheatsheet.md
git -C /home/acuervo/dotfiles commit -m "docs(tmux): document muscle-memory key grammar"
```

Expected: one commit containing only `tmux-cheatsheet.md`.

### Task 3: Validate in an isolated tmux server

**Files:**
- Read-only validation of `stow/tmux/.tmux.conf`.

- [ ] **Step 1: Start a disposable server with a unique socket.**

Run:

```bash
tmux -L tmux-key-grammar-test -f /home/acuervo/dotfiles/stow/tmux/.tmux.conf new-session -d -s verify -c /home/acuervo/dotfiles
```

Expected: exit code 0 and a `verify` session.

- [ ] **Step 2: Inspect the resolved bindings.**

Run:

```bash
tmux -L tmux-key-grammar-test list-keys -T prefix | rg 'bind-key|select-pane|split-window|source-file|restore.sh|display-panes|new-window'
```

Expected: `d`/`r` split, `R` reload, `U` restore, `h/j/k/l` navigation, `H/J/K/L` resize, `c` new window, and `s/S` session/project selection.

- [ ] **Step 3: Exercise non-destructive commands.**

Run:

```bash
tmux -L tmux-key-grammar-test list-sessions
tmux -L tmux-key-grammar-test list-windows -t verify
tmux -L tmux-key-grammar-test list-panes -t verify
```

Expected: all commands return successfully and the server remains alive.

- [ ] **Step 4: Stop only the disposable server.**

Run:

```bash
tmux -L tmux-key-grammar-test kill-server
```

Expected: no impact on any normal tmux server.

### Task 4: Activate with rollback checkpoint

- [ ] **Step 1: Check the working tree.**

Run `git -C /home/acuervo/dotfiles status --short` and confirm unrelated pre-existing changes remain unstaged.

- [ ] **Step 2: Reload the active tmux server.**

Run `tmux source-file /home/acuervo/.tmux.conf`.

Expected: tmux reports the reload message and existing sessions remain attached.

- [ ] **Step 3: Smoke-test the muscle path manually.**

In one disposable pane, verify `C-s d`, `C-s r`, `C-s h/j/k/l`, `C-s H/J/K/L`, `C-s z`, `C-s c`, `C-s s`, `C-s R`, and `C-s U`. Verify Vim navigation and copy-mode afterward.

- [ ] **Step 4: Roll back only if activation fails.**

Restore `/home/acuervo/dotfiles/stow/tmux/.tmux.conf` from `/home/acuervo/backups/tmux-audit-20260830-203649/dotfiles/stow/tmux/.tmux.conf`, then reload the active server. Do not alter unrelated files.
