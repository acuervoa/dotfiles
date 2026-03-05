# Non-Electron Apps Consistency (Phase 3) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align non‑Electron apps (flameshot, albert, copyq, rclone, Nextcloud) with Catppuccin Mocha visuals and move secrets out of dotfiles.

**Architecture:** Create stow packages for each app. Keep only non‑sensitive config in the repo, place secrets in `~/.local/share`, and symlink from `~/.config`. Apply Catppuccin Mocha colors and MesloLGLDZ Nerd Font 10 where supported.

**Tech Stack:** i3 desktop apps, CopyQ, Albert, Flameshot, rclone, Nextcloud

---

### Task 1: Create stow packages and move safe configs

**Files:**
- Create: `stow/flameshot/.config/flameshot/flameshot.ini`
- Create: `stow/albert/.config/albert/config`
- Create: `stow/albert/.config/albert/themes/Catppuccin Mocha.ini`
- Create: `stow/copyq/.config/copyq/copyq.conf`
- Create: `stow/copyq/.config/copyq/copyq-commands.ini`
- Create: `stow/copyq/.config/copyq/copyq_tabs.ini`
- Create: `stow/copyq/.config/copyq/themes/catppuccin-mocha.ini`
- Create: `stow/copyq/.config/copyq/.gitignore`
- Create: `stow/rclone/.config/rclone/rclone.conf.example`
- Create: `stow/rclone/.config/rclone/.gitignore`
- Create: `stow/Nextcloud/.config/Nextcloud/nextcloud.cfg.example`
- Create: `stow/Nextcloud/.config/Nextcloud/sync-exclude.lst`
- Create: `stow/Nextcloud/.config/Nextcloud/.gitignore`

**Step 1: Write the failing test**

Run:
```
test -d stow/flameshot && echo OK || echo MISSING
test -d stow/albert && echo OK || echo MISSING
test -d stow/copyq && echo OK || echo MISSING
test -d stow/rclone && echo OK || echo MISSING
test -d stow/Nextcloud && echo OK || echo MISSING
```
Expected: all show `MISSING` (packages not present yet).

**Step 2: Create stow package directories**

Run:
```
mkdir -p stow/flameshot/.config/flameshot
mkdir -p stow/albert/.config/albert/themes
mkdir -p stow/copyq/.config/copyq/themes
mkdir -p stow/rclone/.config/rclone
mkdir -p stow/Nextcloud/.config/Nextcloud
```

**Step 3: Copy safe local configs into stow**

Run:
```
cp -f ~/.config/flameshot/flameshot.ini stow/flameshot/.config/flameshot/flameshot.ini
cp -f ~/.config/albert/config stow/albert/.config/albert/config
cp -f ~/.config/copyq/copyq.conf stow/copyq/.config/copyq/copyq.conf
cp -f ~/.config/copyq/copyq-commands.ini stow/copyq/.config/copyq/copyq-commands.ini
cp -f ~/.config/copyq/copyq_tabs.ini stow/copyq/.config/copyq/copyq_tabs.ini
cp -f ~/.config/Nextcloud/sync-exclude.lst stow/Nextcloud/.config/Nextcloud/sync-exclude.lst
```

**Step 4: Add gitignore files to avoid runtime data**

Create `stow/copyq/.config/copyq/.gitignore`:
```
*.dat
*.lock
.copyq_s
copyq_geometry.ini
copyq_geometry.ini.lock*
copyq-monitor.ini
```

Create `stow/rclone/.config/rclone/.gitignore`:
```
rclone.conf
```

Create `stow/Nextcloud/.config/Nextcloud/.gitignore`:
```
nextcloud.cfg
nextcloud.cfg.backup_*
cookies0.db
logs/
```

**Step 5: Commit**

```
git add stow/flameshot stow/albert stow/copyq stow/rclone stow/Nextcloud
git commit -m "chore(apps): add non-electron app stow packages"
```

---

### Task 2: Catppuccin colors for Flameshot

**Files:**
- Modify: `stow/flameshot/.config/flameshot/flameshot.ini`

**Step 1: Write the failing test**

Run:
```
rg "uiColor|drawColor" stow/flameshot/.config/flameshot/flameshot.ini
```
Expected: no matches (colors not set yet).

**Step 2: Apply Catppuccin Mocha colors**

Edit `stow/flameshot/.config/flameshot/flameshot.ini`:
```
[General]
uiColor=#89b4fa
drawColor=#f38ba8
contrastOpacity=188
```

**Step 3: Re-run the test**

Run:
```
rg "uiColor|drawColor" stow/flameshot/.config/flameshot/flameshot.ini
```
Expected: both keys present.

**Step 4: Commit**

```
git add stow/flameshot/.config/flameshot/flameshot.ini
git commit -m "chore(flameshot): apply catppuccin colors"
```

---

### Task 3: Catppuccin theme for Albert

**Files:**
- Modify: `stow/albert/.config/albert/config`
- Create: `stow/albert/.config/albert/themes/Catppuccin Mocha.ini`

**Step 1: Write the failing test**

Run:
```
rg "Catppuccin Mocha" stow/albert/.config/albert/config stow/albert/.config/albert/themes/Catppuccin\ Mocha.ini
```
Expected: no matches.

**Step 2: Create Albert Catppuccin theme**

Create `stow/albert/.config/albert/themes/Catppuccin Mocha.ini`:
```
[palette]
base=#1e1e2e
text=#cdd6f4
window=#1e1e2e
window_text=#cdd6f4
button=#313244
button_text=#cdd6f4
highlight=#89b4fa
highlight_text=#1e1e2e
placeholder_text=#a6adc8
link=#89b4fa
link_visited=#cba6f7
```

**Step 3: Point Albert to the new theme**

Edit `stow/albert/.config/albert/config`:
```
[widgetsboxmodel-ng]
darkTheme=Catppuccin Mocha
lightTheme=Catppuccin Mocha
```

**Step 4: Re-run the test**

Run:
```
rg "Catppuccin Mocha" stow/albert/.config/albert/config stow/albert/.config/albert/themes/Catppuccin\ Mocha.ini
```
Expected: matches present.

**Step 5: Commit**

```
git add stow/albert/.config/albert/config stow/albert/.config/albert/themes/Catppuccin\ Mocha.ini
git commit -m "chore(albert): add catppuccin theme"
```

---

### Task 4: Catppuccin theme for CopyQ

**Files:**
- Modify: `stow/copyq/.config/copyq/copyq.conf`
- Create: `stow/copyq/.config/copyq/themes/catppuccin-mocha.ini`

**Step 1: Write the failing test**

Run:
```
rg "catppuccin" stow/copyq/.config/copyq/copyq.conf stow/copyq/.config/copyq/themes/catppuccin-mocha.ini
```
Expected: no matches.

**Step 2: Create CopyQ Catppuccin theme**

Create `stow/copyq/.config/copyq/themes/catppuccin-mocha.ini`:
```
[General]
bg=#1e1e2e
fg=#cdd6f4
alt_bg=#313244
sel_bg=#45475a
sel_fg=#cdd6f4
num_fg=#a6adc8
edit_bg=#1e1e2e
edit_fg=#cdd6f4
notes_bg=#1e1e2e
notes_fg=#cdd6f4
find_bg=#89b4fa
find_fg=#1e1e2e
font="MesloLGLDZ Nerd Font,10,-1,5,50,0,0,0,0,0"
edit_font="MesloLGLDZ Nerd Font,10,-1,5,50,0,0,0,0,0"
find_font="MesloLGLDZ Nerd Font,10,-1,5,50,0,0,0,0,0"
notes_font="MesloLGLDZ Nerd Font,10,-1,5,50,0,0,0,0,0"
num_font="MesloLGLDZ Nerd Font,8,-1,5,25,0,0,0,0,0"
```

**Step 3: Set CopyQ to use the new theme**

Edit `stow/copyq/.config/copyq/copyq.conf`:
```
[Options]
theme=catppuccin-mocha
```

**Step 4: Re-run the test**

Run:
```
rg "catppuccin" stow/copyq/.config/copyq/copyq.conf stow/copyq/.config/copyq/themes/catppuccin-mocha.ini
```
Expected: matches present.

**Step 5: Commit**

```
git add stow/copyq/.config/copyq/copyq.conf stow/copyq/.config/copyq/themes/catppuccin-mocha.ini
git commit -m "chore(copyq): add catppuccin theme"
```

---

### Task 5: Sanitize rclone and Nextcloud secrets

**Files:**
- Create: `stow/rclone/.config/rclone/rclone.conf.example`
- Create: `stow/Nextcloud/.config/Nextcloud/nextcloud.cfg.example`

**Step 1: Write the failing test**

Run:
```
test -f stow/rclone/.config/rclone/rclone.conf.example && echo OK || echo MISSING
test -f stow/Nextcloud/.config/Nextcloud/nextcloud.cfg.example && echo OK || echo MISSING
```
Expected: MISSING.

**Step 2: Create sanitized rclone example**

Create `stow/rclone/.config/rclone/rclone.conf.example`:
```
[mydrive]
type = drive
scope = drive
token = {"access_token":"REDACTED","refresh_token":"REDACTED","token_type":"Bearer","expiry":"1970-01-01T00:00:00Z"}

[iCloud]
type = webdav
url = https://www.icloud.com
vendor = rclone
user = you@example.com
pass = REDACTED
```

**Step 3: Create sanitized Nextcloud example**

Create `stow/Nextcloud/.config/Nextcloud/nextcloud.cfg.example`:
```
[General]
clientVersion=3.x
launchOnSystemStartup=true

[Accounts]
0\authType=webflow
0\displayName=you@example.com
0\url=https://example.com
```

**Step 4: Move real configs to local share and symlink**

Run:
```
mkdir -p ~/.local/share/rclone ~/.local/share/Nextcloud
mv ~/.config/rclone/rclone.conf ~/.local/share/rclone/rclone.conf
mv ~/.config/Nextcloud/nextcloud.cfg ~/.local/share/Nextcloud/nextcloud.cfg
ln -sf ~/.local/share/rclone/rclone.conf ~/.config/rclone/rclone.conf
ln -sf ~/.local/share/Nextcloud/nextcloud.cfg ~/.config/Nextcloud/nextcloud.cfg
```

**Step 5: Commit**

```
git add stow/rclone/.config/rclone/rclone.conf.example stow/Nextcloud/.config/Nextcloud/nextcloud.cfg.example
git commit -m "chore(secrets): add sanitized rclone/nextcloud examples"
```

---

### Task 6: Reload apps to verify

**Files:**
- Verify: `stow/flameshot/.config/flameshot/flameshot.ini`
- Verify: `stow/albert/.config/albert/config`
- Verify: `stow/copyq/.config/copyq/copyq.conf`

**Step 1: Restart Flameshot**

Run:
```
pkill flameshot || true
flameshot &
```

**Step 2: Restart Albert**

Run:
```
pkill albert || true
albert &
```

**Step 3: Restart CopyQ**

Run:
```
copyq exit || true
copyq &
```

**Step 4: Visual check**

- Open Flameshot and verify toolbar colors.
- Open Albert and verify theme.
- Open CopyQ and verify theme.

**Step 5: Commit (only if adjustments needed)**

```
git add <changed files>
git commit -m "chore(ui): tweak app theming"
```
