# Project-aware Devroom Logs Implementation Plan

> **For agentic workers:** Execute the tasks in order and keep the checklist updated.

**Goal:** Make the `dev` room start a useful logs pane for projects whose Compose file is under `docker/`, while avoiding misleading `mise` errors when no task configuration exists.

**Architecture:** Keep the existing three-pane layout and editor/shell behavior. Replace the inline logs fallback with a small project-aware command that checks `mise` metadata first, discovers Compose files in the project root or `docker/`, and reports a concise actionable message when no log service exists.

**Tech Stack:** Bash, tmux, Docker Compose, mise.

---

### Task 1: Contract test for project-aware log selection

**Files:**
- Modify: `tests/application_workflow_contract_test.sh`

- [x] Add assertions that the dev workflow checks `mise.toml`/`.mise.toml`, checks `docker/docker-compose.yml`, and invokes Compose with `-f`.
- [x] Run the test and confirm it fails because the current inline command does not satisfy the contract.

### Task 2: Replace the noisy inline log fallback

**Files:**
- Modify: `stow/bash/.bash_lib/misc.sh`

- [x] Make the logs command skip `mise` unless a mise file exists.
- [x] Discover `docker-compose.yml`, `compose.yml`, `compose.yaml`, and their `docker/` equivalents.
- [x] Use the discovered file with `docker compose -f` and follow `openresty`, `php`, or `php-nginx` when that service exists.
- [x] Print one concise diagnostic and exit successfully when no supported log service is available.

### Task 3: Validate the active workflow

**Files:**
- Test: `tests/application_workflow_contract_test.sh`
- Test: `scripts/check-desktop-configs.sh --static`

- [x] Run Bash syntax and ShellCheck checks for the modified library.
- [x] Run the contract and desktop configuration tests.
- [x] Execute the resulting command in `db-dms-middle` and confirm it discovers `docker/docker-compose.yml` without the previous root-level Compose error.

### Task 4: Commit the focused change

- [x] Run `git diff --check`.
- [x] Commit the test and implementation as `fix(devroom): detect project log configuration`.
