# AgentMemory User Service Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move AgentMemory startup out of every Bash shell and into one persistent `systemd --user` service.

**Architecture:** Add a Stow-managed user unit using the stable `fnm/default` AgentMemory entrypoint. Remove only the Bash health-check/autostart block, then validate the unit statically before enabling it and checking runtime readiness.

**Tech Stack:** Bash 5.3, systemd user units, journald, AgentMemory 0.9.22, iii-engine.

---

### Task 1: Add regression tests for the ownership change

**Files:**
- Create: `tests/agentmemory_service_test.sh`

- [x] **Step 1: Assert the service entrypoint and unit contract.**

The test must assert that
`/home/acuervo/.local/share/fnm/aliases/default/bin/agentmemory` exists and is
executable, that the unit contains `Restart=on-failure`, `RestartSec=5`, and
`WantedBy=default.target`, and that it does not contain `EnvironmentFile`,
known credential variable names, or literal secret-like values.

- [x] **Step 2: Assert Bash no longer owns AgentMemory startup.**

The test must fail while `.bashrc` contains both the health URL and the
`nohup agentmemory` launch, and pass once neither appears. It must not source
`.bashrc` or `.bashrc_local`.

- [x] **Step 3: Run the test before implementation.**

Run:

```bash
bash tests/agentmemory_service_test.sh
```

Expected: FAIL because the unit does not yet exist and `.bashrc` still owns
the launch.

### Task 2: Create the user service and remove shell autostart

**Files:**
- Create: `stow/systemd/.config/systemd/user/agentmemory.service`
- Modify: `stow/bash/.bashrc`

- [x] **Step 1: Add the unit file.**

Use this exact unit contract:

```ini
[Unit]
Description=AgentMemory persistent memory service
After=basic.target

[Service]
Type=simple
ExecStart=/home/acuervo/.local/share/fnm/aliases/default/bin/agentmemory
Restart=on-failure
RestartSec=5
Environment=HOME=/home/acuervo
Environment=PATH=/home/acuervo/.local/share/fnm/aliases/default/bin:/usr/local/bin:/usr/bin:/bin

[Install]
WantedBy=default.target
```

Do not add API keys, tokens, `AGENTMEMORY_SECRET`, or an `EnvironmentFile`.
The CLI reads its own user configuration from its normal home directory.

- [x] **Step 2: Remove only the Bash autostart block.**

Delete the comment and nested conditional that calls `curl` on
`127.0.0.1:3111/agentmemory/health` and launches `nohup agentmemory`. Keep
the AI Flow aliases and all AI functions unchanged.

- [x] **Step 3: Run static tests.**

Run:

```bash
bash tests/agentmemory_service_test.sh
bash -n stow/bash/.bashrc stow/bash/.bash_profile stow/bash/.profile stow/bash/.bash_aliases stow/bash/.bash_functions stow/bash/.bash_lib/*.sh
systemd-analyze verify stow/systemd/.config/systemd/user/agentmemory.service
git diff --check
```

Expected: all commands pass and no tmux/i3 files are changed.

### Task 3: Install and activate the service safely

**Files:**
- No additional files.

- [x] **Step 1: Verify the Stow target and entrypoint.**

Confirm that `$HOME/.config/systemd/user` exists or can receive the Stow link,
and that the `fnm/default` AgentMemory entrypoint resolves to an executable.
Do not overwrite unrelated units.

- [x] **Step 2: Stow only the systemd package.**

Run from the repository:

```bash
stow -d stow -t "$HOME" -S systemd
```

If Stow reports a conflict, stop and inspect that exact target instead of
overwriting it.

- [x] **Step 3: Reload and enable the user unit.**

Run:

```bash
systemctl --user daemon-reload
systemctl --user enable --now agentmemory.service
```

If the user bus is unavailable, report the blocker and do not claim runtime
activation.

- [x] **Step 4: Verify readiness and bounded process count.**

Run:

```bash
systemctl --user is-active agentmemory.service
systemctl --user status --no-pager agentmemory.service
curl --fail --silent --show-error --max-time 3 http://127.0.0.1:3111/agentmemory/health
pgrep -a -u "$(id -u)" -f 'agentmemory|iii-engine'
```

Expected: service active, health response successful, and at most one
AgentMemory worker plus its intended single `iii-engine` process.

### Task 4: Prove Bash startup no longer launches AgentMemory

**Files:**
- No additional files.

- [x] **Step 1: Run repeated interactive shells.**

Run five shells and capture only their exit status and the count of matching
processes before and after. Do not print environment variables or logs that
could contain credentials.

- [x] **Step 2: Measure startup after decoupling.**

Measure eight `bash -ic exit` runs and compare them with the earlier baseline.
The result must show no AgentMemory launch from Bash; no exact latency target is
required if other integrations remain unchanged.

- [x] **Step 3: Confirm scope and commit.**

Run:

```bash
git diff --name-only
git diff --check
```

Confirm only `stow/bash/.bashrc`, the new systemd unit, and the test are
changed, then commit:

```bash
git add stow/bash/.bashrc stow/systemd/.config/systemd/user/agentmemory.service tests/agentmemory_service_test.sh
git commit -m "fix(bash): run agentmemory as user service"
```
