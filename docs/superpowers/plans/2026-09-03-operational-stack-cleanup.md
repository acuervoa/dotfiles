# Operational Stack Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Synchronize active Stow ownership, AgentMemory, Restic, and status documentation with the current stack.

**Architecture:** Preserve the existing Stow/profile/generator design. Remove retired tools from active sources, make AgentMemory independent of fnm, and align Restic metadata with the already-implemented weekly policy. Historical records remain unchanged.

**Tech Stack:** Bash, GNU Stow, systemd user units, Restic, Markdown, ShellCheck, Bash contract tests.

---

### Task 1: Add regression contracts

**Files:**
- Modify: `tests/application_ownership_test.sh`
- Modify: `tests/agentmemory_service_test.sh`
- Create: `tests/restic_contract_test.sh`

- [ ] **Step 1: Update ownership expectations**

Require active records for Kitty, Rofi, Dunst, Polybar, clipmenu, ble.sh, Atuin, FZF, Starship, zoxide, direnv, mise, LazyGit, Yazi, lnav, btop, and Neovim. Explicitly reject active records for Albert, CopyQ, and fnm.

- [ ] **Step 2: Lock the AgentMemory path contract**

Replace the fnm executable existence assertion with:

```bash
grep -q '^ExecStart=%h/.local/bin/agentmemory$' "$unit" || fail "AgentMemory no usa el entrypoint estable"
if grep -q 'fnm' "$unit"; then
  fail "AgentMemory todavía depende de fnm"
fi
```

Keep lifecycle, secret, install-target, and Bash-ownership assertions.

- [ ] **Step 3: Add the Restic contract test**

Create `tests/restic_contract_test.sh` asserting the timer has `OnCalendar=Sat *-*-* 02:00:00`, `Persistent=true`, and `RandomizedDelaySec=15min`; the script has `--keep-weekly 8`, `--keep-monthly 12`, and `--keep-yearly 2`; and the timer description contains no obsolete `diario` wording.

- [ ] **Step 4: Run tests before implementation**

```bash
bash tests/application_ownership_test.sh
bash tests/agentmemory_service_test.sh
bash tests/restic_contract_test.sh
```

Expected: new assertions fail against stale active sources. Commit as `test: lock current stack ownership contracts`.

### Task 2: Synchronize active ownership

**Files:**
- Modify: `stow/dotfiles/.config/dotfiles/hosts/default.sh`
- Modify: `scripts/audit-application-ownership.sh`
- Modify: `tests/application_ownership_test.sh`
- Modify: `TOOLS.md` (generated)

- [ ] **Step 1: Remove retired GUI packages**

Remove `albert` and `copyq` from `CONFIG_GUI_PKGS`, preserving the remaining order.

- [ ] **Step 2: Update the inventory source**

Remove active records for Albert, CopyQ, fnm, and ripgrep-all from the `apps` array. Keep capability ownership and active records for Rofi, clipmenu, and mise.

- [ ] **Step 3: Regenerate documentation**

```bash
bash scripts/generate_tools_doc.sh > TOOLS.md
```

- [ ] **Step 4: Verify and commit**

```bash
bash tests/application_ownership_test.sh
bash scripts/audit-application-ownership.sh
git add stow/dotfiles/.config/dotfiles/hosts/default.sh scripts/audit-application-ownership.sh tests/application_ownership_test.sh TOOLS.md
git commit -m "chore: sync active tool ownership"
```

Expected: PASS and no active records for the retired tools.

### Task 3: Decouple AgentMemory from fnm

**Files:**
- Modify: `stow/systemd/.config/systemd/user/agentmemory.service`
- Modify: `tests/agentmemory_service_test.sh`

- [ ] **Step 1: Use the stable user-local executable**

Set:

```ini
ExecStart=%h/.local/bin/agentmemory
Environment=PATH=%h/.local/bin:/usr/local/bin:/usr/bin:/bin
```

Keep `Restart=on-failure`, `RestartSec=5`, `HOME=/home/acuervo` equivalent behavior, `WantedBy=default.target`, and no secrets or `EnvironmentFile`.

- [ ] **Step 2: Verify and commit**

```bash
bash tests/agentmemory_service_test.sh
systemd-analyze verify stow/systemd/.config/systemd/user/agentmemory.service
git add stow/systemd/.config/systemd/user/agentmemory.service tests/agentmemory_service_test.sh
git commit -m "fix: decouple agentmemory service from fnm"
```

Do not enable, restart, or inspect the runtime service.

### Task 4: Align Restic and operational status

**Files:**
- Modify: `stow/systemd/.config/systemd/user/restic-backup.timer`
- Modify: `docs/inventario-aplicaciones-2026-09-03.md`
- Modify: `docs/status.md`
- Test: `tests/restic_contract_test.sh`

- [ ] **Step 1: Correct active Restic metadata**

Describe the timer as weekly Saturday execution; preserve its schedule, persistence, delay, and install target. Update inventory retention to `8 semanales / 12 mensuales / 2 anuales`.

- [ ] **Step 2: Refresh status snapshot**

State i3 as sole configured WM, Rofi as launcher, clipmenu as clipboard owner, mise as runtime manager, and Restic as active backup. Remove stale active claims about niri, Albert, CopyQ, and `cleanup-configs.timer`. Do not rewrite historical audits.

- [ ] **Step 3: Verify and commit**

```bash
bash tests/restic_contract_test.sh
systemd-analyze verify stow/systemd/.config/systemd/user/restic-backup.service stow/systemd/.config/systemd/user/restic-backup.timer
git add stow/systemd/.config/systemd/user/restic-backup.timer docs/inventario-aplicaciones-2026-09-03.md docs/status.md tests/restic_contract_test.sh
git commit -m "docs: align restic operational policy"
```

Do not run Restic, systemctl, Stow, bootstrap, rollback, or the backup script.

### Task 5: Full verification

**Files:**
- Test: `tests/*_test.sh`

- [ ] **Step 1: Check syntax and changed shell files**

```bash
bash -n scripts/*.sh stow/bash/.bash_lib/*.sh stow/bin/.local/bin/*.sh stow/i3/.config/i3/scripts/*.sh
shellcheck scripts/audit-application-ownership.sh stow/bin/.local/bin/restic-backup.sh stow/i3/.config/i3/scripts/*.sh
```

- [ ] **Step 2: Run repository verification**

```bash
bash scripts/verify.sh
```

Report optional external health-check limitations explicitly.

- [ ] **Step 3: Run every contract test**

```bash
for test in tests/*_test.sh; do bash "$test"; done
```

- [ ] **Step 4: Review changes**

```bash
git diff --check
git status --short --branch
git log -5 --oneline
```

Confirm pre-existing user changes remain separate and no command modified `$HOME`.
