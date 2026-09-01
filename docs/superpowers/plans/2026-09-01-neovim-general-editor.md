# Neovim General Editor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the existing Neovim setup into a reliable general-purpose editor with a particularly strong backend workflow while preserving current mappings, commands, languages, tmux integration, and Codex behavior.

**Architecture:** Keep `init.lua` and `lua/config/` responsible for global behavior, keep plugin specs in `lua/plugins/`, and keep language behavior in `lua/lang/`. First add reproducible headless checks, then consolidate duplicate plugin ownership, then validate workflows and apply only measured performance changes.

**Tech Stack:** Neovim 0.11+, Lua, lazy.nvim, Mason, nvim-treesitter, blink.cmp, LSP, conform.nvim, nvim-lint, DAP, neotest, Overseer, Telescope, Neo-tree, tmux-navigator and Codex.

---

## File map and invariants

- `init.lua` and `lua/config/*.lua`: bootstrap, options, autocmds, mappings, environment and lazy loading.
- `lua/plugins/*.lua`: one lazy.nvim specification per capability/plugin.
- `lua/lang/*.lua`: language-specific LSP, formatter, linter, tests and DAP.
- `lua/codex/*.lua`: Codex commands and unit-testable helpers.
- `scripts/check-nvim.sh`: reproducible headless validation.
- `tests/nvim_*_test.sh`: shell-level contracts for config, mappings, ownership and workflows.
- `docs/baselines/nvim-2026-09-01.md`: before/after measurements.

Protected: `.bashrc_local`, `stow/tmux/.tmux.conf`, and `stow/i3/.config/i3/config` do not change.

### Task 1: Establish the Neovim baseline

**Files:** Create `scripts/check-nvim.sh`, `tests/nvim_config_test.sh`, and `docs/baselines/nvim-2026-09-01.md`; modify `.github/workflows/ci.yml`.

- [ ] **Step 1: Write the failing contract test**

```bash
#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check="$repo_root/scripts/check-nvim.sh"
test -x "$check"
bash "$check" --static
bash "$check" --help | grep -Fq 'Validación headless'
printf 'PASS: contrato del checker Neovim\n'
```

- [ ] **Step 2: Verify red**

Run `bash tests/nvim_config_test.sh`; it must fail because the checker does not exist.

- [ ] **Step 3: Implement the checker**

`check-nvim.sh` accepts `--static`, `--headless`, and `--strict`. Static mode
checks every `init.lua`, `config/*.lua`, `plugins/*.lua`, `lang/*.lua`, and
`codex/*.lua` file and runs `luac` when available. Headless mode runs:

```bash
nvim --headless -u "$config/init.lua" '+qa'
nvim --headless -u "$config/init.lua" '+lua assert(vim.g.mapleader == " ")' '+qa'
```

Missing Neovim is a warning unless `--strict` is set. The checker never writes
the repository and uses temporary XDG directories only in explicit isolated mode.

- [ ] **Step 4: Verify green**

Run `chmod +x scripts/check-nvim.sh tests/nvim_config_test.sh`, then
`bash tests/nvim_config_test.sh`, `bash -n scripts/check-nvim.sh tests/nvim_config_test.sh`, and `shellcheck -S warning scripts/check-nvim.sh tests/nvim_config_test.sh`.

- [ ] **Step 5: Capture baseline and add CI**

Record Neovim version, five startup timings, loaded plugin count and health
errors in `docs/baselines/nvim-2026-09-01.md`, without private paths or tokens.
Add `bash ./scripts/check-nvim.sh --static` to CI.

- [ ] **Step 6: Commit**

```bash
git add scripts/check-nvim.sh tests/nvim_config_test.sh .github/workflows/ci.yml docs/baselines/nvim-2026-09-01.md
git commit -m "test(nvim): add reproducible headless baseline"
```

### Task 2: Lock current keymap and command contracts

**Files:** Create `tests/nvim_keymap_test.sh`; inspect `lua/config/keymaps.lua`, `lua/plugins/*.lua`, and `lua/codex/init.lua`.

- [ ] **Step 1: Add the contract test**

Launch Neovim with the versioned `init.lua` and assert via Lua that these
mappings exist: `<leader>w`, `<leader>q`, `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`,
`<leader>ff`, `<leader>fg`, `<leader>cf`, `<leader>tt`, `<leader>db`,
`<leader>ce`, `<leader>cz`, `<leader>cF`, `<leader>cr`, and `<leader>cD`.
Also assert the commands `CodexExplain`, `CodexExplainRepo`, `CodexFix`,
`CodexRefactor`, `CodexDiff`, and `CodexVisual` exist.

- [ ] **Step 2: Run and record baseline**

Run `bash tests/nvim_keymap_test.sh`. A failure is a baseline defect to
investigate, not permission to redesign mappings.

- [ ] **Step 3: Commit**

```bash
git add tests/nvim_keymap_test.sh
git commit -m "test(nvim): lock current keymap contracts"
```

### Task 3: Consolidate duplicate plugin ownership

**Files:** Modify `lua/plugins/comment.lua`, `lua/plugins/editing.lua`, and
`lua/plugins/treesitter.lua`; create `tests/nvim_plugin_ownership_test.sh`.

- [ ] **Step 1: Write the failing ownership test**

Count active repository declarations in `lua/plugins/*.lua`, ignoring lines
whose first non-space characters are `--`. Assert one active declaration for
`numToStr/Comment.nvim` and one for
`JoosepAlviste/nvim-ts-context-commentstring`.

- [ ] **Step 2: Run red and inspect conflicts**

Run `bash tests/nvim_plugin_ownership_test.sh`; it must expose the duplicate
Comment/context-commentstring declarations.

- [ ] **Step 3: Keep the richer owner**

Keep the event/keys/configuration in `editing.lua`. Remove the redundant active
declaration in `comment.lua` and the duplicate active context-commentstring
setup in `treesitter.lua`. Do not change mappings, versions or language support.

- [ ] **Step 4: Verify and commit**

Run the ownership test, `bash scripts/check-nvim.sh --headless`, and this
headless Codex contract (the repository currently has no standalone Lua test
runner):

```bash
nvim --headless -u stow/nvim/.config/nvim/init.lua '+lua local c=require("codex"); assert(type(c.__test) == "table")' '+qa'
```

Then run `git diff --check` and:

```bash
git add stow/nvim/.config/nvim/lua/plugins/comment.lua stow/nvim/.config/nvim/lua/plugins/editing.lua stow/nvim/.config/nvim/lua/plugins/treesitter.lua tests/nvim_plugin_ownership_test.sh
git commit -m "fix(nvim): consolidate duplicate plugin ownership"
```

### Task 4: Validate general and backend workflows

**Files:** Create `docs/audits/2026-09-01-neovim-workflows.md` and
`tests/nvim_workflow_contract_test.sh`; update
`stow/nvim/.config/nvim/SHORTCUTS.md` and `USAGE.md` only after tests pass.

- [ ] **Step 1: Add non-mutating workflow contracts**

Assert stable entry points for files/search, buffers, diagnostics, format,
lint, tests, DAP, tasks, Git and Codex. Check mappings and commands only; do
not run Docker, migrations, project tests or network operations.

- [ ] **Step 2: Document exact workflows**

Document general navigation, PHP/Laravel with Docker/tests/Xdebug, Git review,
Codex review, and tmux terminal navigation. Mark optional external commands
and fallbacks. Keep all existing mappings unchanged.

- [ ] **Step 3: Verify and commit**

Run the workflow contract, `git diff --check`, and regenerate any shortcut
document only from validated mappings:

```bash
git add docs/audits/2026-09-01-neovim-workflows.md tests/nvim_workflow_contract_test.sh stow/nvim/.config/nvim/SHORTCUTS.md stow/nvim/.config/nvim/USAGE.md
git commit -m "docs(nvim): document general and backend workflows"
```

### Task 5: Measure and optimize only if justified

**Files:** Modify `lua/config/lazy.lua` or plugin specs only if measurements
justify it; update `docs/baselines/nvim-2026-09-01.md`; create
`tests/nvim_performance_test.sh` if a regression-sensitive change is needed.

- [ ] **Step 1: Capture five-run measurements**

Use `nvim --startuptime` for cold/warm runs and Lazy profile output where
available. Record medians for normal startup and first use of Telescope, LSP,
tests, DAP and Codex.

- [ ] **Step 2: Inventory eager loading**

List every `lazy = false`, `VeryLazy`, and broad startup event. For each, name
the mapping/command that must remain available.

- [ ] **Step 3: Apply one measured change or document no change**

Lazy-load only an expensive plugin whose existing command/key/event can be
preserved. Do not add plugins or update the lockfile by routine. If no
meaningful improvement is demonstrated, keep the configuration unchanged.

- [ ] **Step 4: Verify and commit conditionally**

Require no regression in headless startup, mapping availability, backend
language loading or tmux navigation. Commit only an evidence-backed change:

```bash
git add docs/baselines/nvim-2026-09-01.md stow/nvim/.config/nvim/lua/config/lazy.lua stow/nvim/.config/nvim/lua/plugins
git commit -m "perf(nvim): defer measured startup cost"
```

### Task 6: Final validation and release

**Files:** Modify only validated Neovim files and `docs/status.md` if claims
become stale.

- [ ] **Step 1: Run the full matrix**

```bash
bash scripts/check.sh
bash scripts/check-nvim.sh --strict
bash tests/nvim_config_test.sh
bash tests/nvim_keymap_test.sh
bash tests/nvim_plugin_ownership_test.sh
bash tests/nvim_workflow_contract_test.sh
bash scripts/check-secrets.sh
git diff --check
```

Also run `nvim --headless '+checkhealth' '+qa'` and verify tmux navigation
without changing tmux.

- [ ] **Step 2: Check protected paths and generated drift**

Run `git diff --name-only HEAD~N..HEAD -- .bashrc_local stow/tmux stow/i3`.
Expected: no protected files. Confirm `lazy-lock.json` changed only when an
explicit validated update required it.

- [ ] **Step 3: Commit final documentation**

```bash
git add docs/status.md stow/nvim/.config/nvim
git commit -m "chore(nvim): close editor modernization validation"
```

- [ ] **Step 4: Release separately**

After fresh verification, create a new patch tag and GitHub release; never
reuse `v2026.09.01.1`. Verify main, tag and release point to the same commit.

## Plan self-review

- Baseline and CI are covered by Task 1; keymap compatibility by Task 2;
  duplicate ownership by Task 3; workflows by Task 4; performance by Task 5;
  final invariants and release by Task 6.
- No plugin additions, language removals, tmux/i3 changes, secret handling or
  automatic signing activation are included.
- Task 5 may intentionally produce no code commit when measurements do not
  justify a change.
