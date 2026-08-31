# i3 Spatial Key Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task with review checkpoints.

**Goal:** Align i3 window management with a spatial `Super` + `h/j/k/l` grammar while preserving tmux unchanged.

**Architecture:** Keep i3's existing focus and move bindings on the home row, add a dedicated `resize` mode entered with `Super+r`, and remove only the duplicate arrow-based resize route. The change is isolated to i3 configuration and its reference documentation; tmux is validated as an external contract after reload.

**Tech Stack:** i3 4.25.1, Kitty, tmux 3.7c, Bash, Markdown.

---

### Task 1: Implement the i3 spatial grammar

**Files:**
- Modify: `stow/i3/.config/i3/config` in the movement and resize sections.

- [ ] **Step 1: Add a dedicated resize mode after the focus/move bindings.**

Add:

```i3
# Resize modal: Super+r entra; h/j/k/l redimensionan; Escape/Return salen.
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Escape mode "default"
    bindsym Return mode "default"
}
bindsym $mod+r mode "resize"
```

- [ ] **Step 2: Remove only arrow-based resize bindings.**

Remove these four lines:

```i3
bindsym $mod+Shift+Left  resize shrink width 10 px or 10 ppt
bindsym $mod+Shift+Right resize grow   width 10 px or 10 ppt
bindsym $mod+Shift+Up    resize grow   height 10 px or 10 ppt
bindsym $mod+Shift+Down  resize shrink height 10 px or 10 ppt
```

Keep focus and move bindings, workspace bindings, and all tmux-related behavior unchanged.

- [ ] **Step 3: Validate i3 syntax before reload.**

Run:

```bash
i3 -C -c /home/acuervo/dotfiles/stow/i3/.config/i3/config
```

Expected: exit status 0.

- [ ] **Step 4: Commit the configuration change.**

```bash
git add stow/i3/.config/i3/config
git commit -m "feat(i3): add spatial resize mode"
```

### Task 2: Update the keymap documentation

**Files:**
- Modify: `keymap-maestro.md`
- Modify: `tmux-cheatsheet.md` only if an i3 cross-reference is stale.

- [ ] **Step 1: Document the resize mode.**

Add the i3 mapping:

```markdown
| `Super+r` | Entrar en modo resize |
| `h/j/k/l` en resize | Redimensionar izquierda/abajo/arriba/derecha |
| `Escape` / `Return` | Salir del modo resize |
```

- [ ] **Step 2: Mark arrow-based resize as retired.**

Do not document `Super+Shift+flechas` as an active resize route.

- [ ] **Step 3: Commit documentation.**

```bash
git add keymap-maestro.md tmux-cheatsheet.md
git commit -m "docs(i3): document spatial resize mode"
```

### Task 3: Reload and verify both window managers

**Files:**
- Read-only runtime verification.

- [ ] **Step 1: Reload i3.**

```bash
i3-msg reload
```

Expected: `[{"success":true}]`.

- [ ] **Step 2: Verify the effective i3 configuration.**

```bash
i3-msg -t get_config | rg 'mode "resize"|mod\\+r|resize (shrink|grow)|mode "default"'
```

Expected: the resize mode, `Super+r`, four home-row resize commands, and exit bindings are present.

- [ ] **Step 3: Verify tmux did not regress.**

```bash
tmux show-options -gqv prefix
tmux list-keys -T prefix | rg 'prefix (h|j|k|l|d|r|p|z) '
```

Expected: prefix `C-s` and canonical tmux bindings remain unchanged.

- [ ] **Step 4: Run repository checks.**

```bash
bash scripts/check.sh
git diff --check
git status -sb
```

Expected: checks pass and only unrelated pre-existing changes, if any, remain unstaged.
