# Core Dev UX Consistency (Phase 1) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align the core dev UX across kitty, tmux, and Neovim by using a single visual theme and consistent font defaults.

**Architecture:** Keep kitty and tmux as the visual baseline (Catppuccin-like palette), then adjust Neovim to match. Make only minimal, low-risk changes and verify them with headless checks.

**Tech Stack:** bash, kitty, tmux, Neovim (lazy.nvim), Lua configs

---

### Task 1: Switch Neovim theme to Catppuccin

**Files:**
- Modify: `stow/nvim/.config/nvim/lua/plugins/ui.lua`
- Modify: `stow/nvim/.config/nvim/lua/config/options.lua`
- Modify (auto): `stow/nvim/.config/nvim/lazy-lock.json`

**Step 1: Write the failing test**

Run:
```
nvim --headless "+lua assert(vim.g.colors_name == 'catppuccin-mocha')" +qa
```
Expected: FAIL (current colorscheme is `vscode`).

**Step 2: Update UI plugins to Catppuccin**

Edit `stow/nvim/.config/nvim/lua/plugins/ui.lua`:

- Replace the VSCode theme block with Catppuccin:
```lua
  -- Tema Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = { lualine = true },
      })
      vim.o.background = "dark"
      vim.cmd.colorscheme("catppuccin")
    end,
  },
```

- Update lualine theme:
```lua
options = { theme = "catppuccin", globalstatus = true, component_separators = "", section_separators = "" },
```

- Update barbecue theme:
```lua
opts = { theme = "catppuccin", show_dirname = false, show_basename = true },
```

**Step 3: Add GUI font default (consistency)**

Edit `stow/nvim/.config/nvim/lua/config/options.lua` and add:
```lua
o.guifont = "MesloLGLDZ Nerd Font:h10"
```

**Step 4: Sync plugins**

Run:
```
nvim --headless "+Lazy! sync" +qa
```
Expected: PASS, `lazy-lock.json` updates with catppuccin entry.

**Step 5: Re-run the test**

Run:
```
nvim --headless "+lua assert(vim.g.colors_name == 'catppuccin-mocha')" +qa
```
Expected: PASS.

**Step 6: Commit**

```
git add stow/nvim/.config/nvim/lua/plugins/ui.lua stow/nvim/.config/nvim/lua/config/options.lua stow/nvim/.config/nvim/lazy-lock.json
git commit -m "feat(nvim): align UI theme with catppuccin"
```

---

### Task 2: Verify kitty/tmux baseline consistency

**Files:**
- Verify: `stow/kitty/.config/kitty/kitty.conf`
- Verify: `stow/tmux/.tmux.conf`

**Step 1: Visual verification checklist**

- kitty uses `MesloLGLDZ Nerd Font` at size `10`.
- kitty background is `#1E1E2E` (Catppuccin-like).
- tmux status colors use the same palette (no change expected).

**Step 2: Manual checks**

Run:
```
tmux source-file ~/.tmux.conf
```
Expected: No errors, status bar colors unchanged.

Open kitty + tmux + nvim and verify:
- colors match across layers
- pane/buffer navigation feels consistent

**Step 3: Commit (only if any changes were needed)**

```
git add stow/kitty/.config/kitty/kitty.conf stow/tmux/.tmux.conf
git commit -m "chore(core): align kitty/tmux with core UX baseline"
```

---

### Task 3: Document UX baseline

**Files:**
- Modify: `README.md` (or `README.en.md` if needed)

**Step 1: Add short note**

Add a short section documenting the UX baseline:
- Font: MesloLGLDZ Nerd Font @ 10
- Theme: Catppuccin (mocha)
- Prefixes: tmux `C-s`, Neovim `Space`

**Step 2: Commit**

```
git add README.md
git commit -m "docs: document core UX baseline"
```
