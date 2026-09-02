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

### Task 5: Optional per-project configuration and expanded discovery

**Files:**
- Modify: `stow/tmux/.tmux/scripts/project_logs.sh`
- Modify: `tests/application_workflow_contract_test.sh`

- [x] Support `.devroom.yml` keys `logs.compose_file` and `logs.service` without adding a mandatory YAML dependency.
- [x] Discover Compose files under `infra/`, `deploy/`, and `.docker/` as well as the project root and `docker/`.
- [x] Recognize generic log services `api`, `app`, `backend`, and `web` after the existing PHP/OpenResty names.
- [x] Validate explicit configuration and autodetection with temporary fixtures based on a valid project Compose file.

### Task 6: Label panes and open the project in the editor

**Files:**
- Modify: `stow/bash/.bash_lib/misc.sh`
- Modify: `tests/application_workflow_contract_test.sh`

- [x] Set `EDITOR`, `LOGS`, and `SHELL` titles on the three panes of the `dev` window.
- [x] Show pane borders only in that window and preserve the titles with `allow-rename off`.
- [x] Start the configured editor with `.` so the project directory replaces `[No Name]`.
- [x] Apply the labels and directory view to the active `db-dms-middle` room and verify the effective tmux options.
