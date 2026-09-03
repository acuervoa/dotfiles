# Operational Inventory, Restic and AgentMemory Cleanup

## Goal

Synchronize the active dotfiles contracts with the current desktop stack and
remove stale runtime references without touching historical audit material or
applying anything to `$HOME`.

## Scope

The change covers four related operational contracts:

1. Active Stow package selection and application ownership inventory.
2. Generated `TOOLS.md` data and its ownership regression tests.
3. The AgentMemory user unit's executable path after `fnm` was retired.
4. Restic's timer/service documentation and the current retention policy.

`docs/audits/`, `docs/plans/`, `docs/superpowers/` historical material and
`CHANGELOG.md` remain unchanged unless a file is an active source or test.

## Design

### Active application ownership

The default profile will stop deploying `albert` and `copyq`. The ownership
audit will describe the current active inventory: Rofi owns the launcher,
clipmenu owns clipboard history, mise owns runtime selection, and Neovim owns
the editor workflow. Retired binaries (`albert`, `copyq`, `fnm`, `rga`) will no
longer appear as active application records. `TOOLS.md` will be regenerated
from that source.

The existing single-owner capability contract remains unchanged. Historical
references explaining why tools were removed are documentation, not active
configuration.

### AgentMemory

The systemd user unit will invoke the stable `agentmemory` command through the
user's executable search path instead of hardcoding the retired fnm alias. The
unit will retain its existing restart policy, non-secret environment, and
`default.target` installation. The test will assert the new command contract
and reject references to the old fnm path.

No service will be enabled, restarted, or inspected at runtime by this change.

### Restic

The repository will use the behavior already implemented by the current
script and timer: weekly execution on Saturday at 02:00 with
`Persistent=true` and randomized delay, followed by retention of 8 weekly, 12
monthly, and 2 yearly snapshots. Active descriptions and inventory text will
match these values.

The backup repository, password file, mount point, excludes, and backup
implementation are not redesigned. No backup or prune operation will run.

### Status documentation

`docs/status.md` will be updated as an operational snapshot: i3 is primary and
sole configured WM, Rofi is the launcher, clipmenu is the clipboard owner,
mise is the runtime manager, and Restic is the active backup path. Historical
decision records stay intact.

## Error handling and safety

- Stow changes affect only the package list in the repository; no Stow apply
  or bootstrap command is run.
- AgentMemory remains restart-on-failure and must not gain secrets or an
  `EnvironmentFile`.
- Restic continues to skip safely when `/mnt/Elements` is not mounted and
  never prunes after a fatal backup error.
- Generated documentation is updated through its existing generator rather
  than hand-maintained rows.

## Verification

The implementation must demonstrate:

- A failing regression test before changing each active contract.
- Passing ownership, AgentMemory, clipboard, and configuration tests.
- `bash -n` for changed shell scripts.
- ShellCheck with no new errors in changed scripts.
- `systemd-analyze verify` for both Restic and AgentMemory units when the tool
  is available.
- `git diff --check` and the repository verification script where the local
  environment supports it.

## Out of scope

- Enabling user services or running `systemctl --user` mutations.
- Running `bootstrap.sh`, `rollback.sh`, `stow`, or any backup command.
- Removing historical references from audits, plans, or changelog entries.
- Broad package-manager cleanup outside this repository.
