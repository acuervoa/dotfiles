# WM/UX Consistency (Phase 2) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align the desktop UI (i3, polybar, rofi, dunst, picom, GTK) with Catppuccin Mocha and a unified MesloLGLDZ Nerd Font size 10, without changing workflows.

**Architecture:** Treat i3 as the primary WM and use it as the base. Normalize fonts and palette across UI components, leaving behavior and keybindings unchanged. GTK config will be added if missing to enforce font and theme.

**Tech Stack:** i3, picom, polybar, rofi, dunst, GTK3/GTK4

---

### Task 1: Unify fonts in i3 and rofi

**Files:**
- Modify: `stow/i3/.config/i3/config`
- Modify: `stow/rofi/.config/rofi/config.rasi`

**Step 1: Write the failing test**

Run:
```
rg "Noto Sans" stow/i3/.config/i3/config stow/rofi/.config/rofi/config.rasi
```
Expected: Finds Noto Sans font entries (current mismatch).

**Step 2: Update i3 rofi font variables**

Edit `stow/i3/.config/i3/config`:
- Change `$rofi` font to `MesloLGLDZ Nerd Font 10`.
- Update rofi binds to use the same font.

Example:
```
set $rofi rofi -font 'MesloLGLDZ Nerd Font 10'
bindsym $mod+d exec --no-startup-id rofi -modi run -show drun -show-icons -font "MesloLGLDZ Nerd Font 10"
bindsym $mod+F11 exec --no-startup-id rofi -show run -fullscreen -font "MesloLGLDZ Nerd Font 10"
bindsym $mod+Shift+d exec --no-startup-id rofi -show window -show-icons -font "MesloLGLDZ Nerd Font 10"
```

**Step 3: Update rofi config font**

Edit `stow/rofi/.config/rofi/config.rasi`:
```
font: "MesloLGLDZ Nerd Font 10";
```

**Step 4: Re-run the test**

Run:
```
rg "Noto Sans" stow/i3/.config/i3/config stow/rofi/.config/rofi/config.rasi
```
Expected: No matches.

**Step 5: Commit**

```
git add stow/i3/.config/i3/config stow/rofi/.config/rofi/config.rasi
git commit -m "chore(i3,rofi): unify font to MesloLGLDZ 10"
```

---

### Task 2: Unify font in dunst

**Files:**
- Modify: `stow/dunst/.config/dunst/dunstrc`

**Step 1: Write the failing test**

Run:
```
rg "^\s*font\s*=\s*" stow/dunst/.config/dunst/dunstrc
```
Expected: Shows `MesloLGS Nerd Font 11` (mismatch).

**Step 2: Update dunst font**

Edit `stow/dunst/.config/dunst/dunstrc`:
```
font = MesloLGLDZ Nerd Font 10
```

**Step 3: Re-run the test**

Run:
```
rg "^\s*font\s*=\s*" stow/dunst/.config/dunst/dunstrc
```
Expected: `MesloLGLDZ Nerd Font 10`.

**Step 4: Commit**

```
git add stow/dunst/.config/dunst/dunstrc
git commit -m "chore(dunst): align font with core UX"
```

---

### Task 3: Normalize fonts in polybar

**Files:**
- Modify: `stow/polybar/.config/polybar/config.ini`

**Step 1: Write the failing test**

Run:
```
rg "font-0" stow/polybar/.config/polybar/config.ini
```
Expected: Two different declarations (size and pixelsize mix).

**Step 2: Normalize font-0 lines**

Edit `stow/polybar/.config/polybar/config.ini`:
- Use consistent `size=10` for all `font-0` entries.
Example:
```
font-0 = "MesloLGLDZ Nerd Font:style=Regular:size=10"
```

**Step 3: Re-run the test**

Run:
```
rg "font-0" stow/polybar/.config/polybar/config.ini
```
Expected: Both bars use the same font line.

**Step 4: Commit**

```
git add stow/polybar/.config/polybar/config.ini
git commit -m "chore(polybar): unify font to MesloLGLDZ 10"
```

---

### Task 4: Add GTK font/theme defaults (if missing)

**Files:**
- Create: `stow/gtk-3.0/.config/gtk-3.0/settings.ini`
- Create: `stow/gtk-4.0/.config/gtk-4.0/settings.ini`

**Step 1: Write the failing test**

Run:
```
test -f stow/gtk-3.0/.config/gtk-3.0/settings.ini && echo GTK3_OK || echo GTK3_MISSING
test -f stow/gtk-4.0/.config/gtk-4.0/settings.ini && echo GTK4_OK || echo GTK4_MISSING
```
Expected: missing (no files currently).

**Step 2: Create GTK3 settings**

Create `stow/gtk-3.0/.config/gtk-3.0/settings.ini`:
```
[Settings]
gtk-theme-name=Catppuccin-Mocha
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=MesloLGLDZ Nerd Font 10
gtk-cursor-theme-name=Catppuccin-Mocha
gtk-cursor-theme-size=24
```

**Step 3: Create GTK4 settings**

Create `stow/gtk-4.0/.config/gtk-4.0/settings.ini`:
```
[Settings]
gtk-theme-name=Catppuccin-Mocha
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=MesloLGLDZ Nerd Font 10
gtk-cursor-theme-name=Catppuccin-Mocha
gtk-cursor-theme-size=24
```

**Step 4: Re-run the test**

Run:
```
test -f stow/gtk-3.0/.config/gtk-3.0/settings.ini && echo GTK3_OK || echo GTK3_MISSING
test -f stow/gtk-4.0/.config/gtk-4.0/settings.ini && echo GTK4_OK || echo GTK4_MISSING
```
Expected: GTK3_OK and GTK4_OK.

**Step 5: Commit**

```
git add stow/gtk-3.0/.config/gtk-3.0/settings.ini stow/gtk-4.0/.config/gtk-4.0/settings.ini
git commit -m "chore(gtk): set font and catppuccin theme"
```

---

### Task 5: Validate UX and reload services

**Files:**
- Verify: `stow/i3/.config/i3/config`
- Verify: `stow/polybar/.config/polybar/config.ini`
- Verify: `stow/rofi/.config/rofi/config.rasi`
- Verify: `stow/dunst/.config/dunst/dunstrc`

**Step 1: Reload i3**

Run:
```
i3-msg reload
```
Expected: no errors.

**Step 2: Reload dunst**

Run:
```
pkill -SIGUSR1 dunst
```
Expected: dunst reloads config.

**Step 3: Restart polybar**

Run:
```
~/.config/polybar/launch.sh
```

**Step 4: Visual check**

- Open rofi and ensure font and spacing look consistent.
- Check dunst notifications and polybar labels.
- Open a GTK app to confirm theme and font.

**Step 5: Commit (only if adjustments needed)**

```
git add <changed files>
git commit -m "chore(ui): tweak spacing after font alignment"
```
