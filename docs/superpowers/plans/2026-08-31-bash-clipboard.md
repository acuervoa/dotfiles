# Bash Clipboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Bash clipboard commands choose the backend from the active graphical protocol and keep `pbcopy`, `pbpaste`, and `cb` consistent.

**Architecture:** Add one internal resolver in `stow/bash/.bash_lib/nav.sh` that fills a command array for copy or paste. Define the public `pbcopy`/`pbpaste` wrappers in `.bashrc` as delegates to that resolver, while `cb` reuses it and preserves its existing file/stdin/OSC52 behavior.

**Tech Stack:** Bash 5.3, shell functions, X11 `xclip`, Wayland `wl-clipboard`, POSIX utilities.

---

### Task 1: Add isolated resolver tests

**Files:**
- Create: `tests/bash_clipboard_test.sh`

- [x] **Step 1: Create a temporary fake command directory and assertions.**

The test must source only the Bash library modules needed by `cb`, prepend fake
`wl-copy`, `wl-paste`, `xclip`, and `xsel` commands to `PATH`, and record which
fake command receives input. Use the real current X11 environment with
`WAYLAND_DISPLAY=` to assert `xclip -selection clipboard`; then set a nonexistent
Wayland display socket to assert that merely setting the variable without a
socket does not select Wayland. Also assert `bash -n` for every Bash file.

- [x] **Step 2: Run the test before implementation.**

Run:

```bash
bash tests/bash_clipboard_test.sh
```

Expected: FAIL because the shared resolver does not yet exist.

### Task 2: Implement one backend policy

**Files:**
- Modify: `stow/bash/.bash_lib/nav.sh` near `cb()`
- Modify: `stow/bash/.bashrc` near the current `pbcopy`/`pbpaste` definitions

- [x] **Step 1: Add `_clipboard_command` in `nav.sh`.**

The function accepts `copy` or `paste`, sets a global array named
`_CLIPBOARD_CMD`, and returns non-zero with a diagnostic when no backend is
available. Selection order must be:

```bash
if [ -n "${WAYLAND_DISPLAY:-}" ] \
  && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$WAYLAND_DISPLAY" ] \
  && command -v wl-copy >/dev/null 2>&1 \
  && command -v wl-paste >/dev/null 2>&1; then
  _CLIPBOARD_CMD=(wl-copy)       # copy
  _CLIPBOARD_CMD=(wl-paste)      # paste
elif [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
  _CLIPBOARD_CMD=(xclip -selection clipboard)       # copy
  _CLIPBOARD_CMD=(xclip -selection clipboard -o)    # paste
elif [ -n "${DISPLAY:-}" ] && command -v xsel >/dev/null 2>&1; then
  _CLIPBOARD_CMD=(xsel --clipboard --input)         # copy
  _CLIPBOARD_CMD=(xsel --clipboard --output)        # paste
elif [ "${OSTYPE:-}" = darwin* ] && command -v pbcopy >/dev/null 2>&1; then
  _CLIPBOARD_CMD=(pbcopy)       # copy
  _CLIPBOARD_CMD=(pbpaste)      # paste
else
  printf 'clipboard: no hay backend disponible (Wayland, X11 o macOS).\n' >&2
  return 1
fi
```

The actual implementation must use valid Bash branching rather than the
comments in this example; keep copy and paste command selection explicit and
check `pbpaste` separately for the paste operation. The copy execution helper
must redirect `xclip` stdout to `/dev/null`, because xclip's selection-owner
process otherwise keeps inherited pipe descriptors open in non-TTY automation.
The diagnostic must name
the supported backends without exposing command-substitution errors.

- [x] **Step 2: Make `pbcopy` and `pbpaste` delegate.**

Replace the current binary-presence check in `.bashrc` with wrappers that call
`_clipboard_command copy` or `paste`, then execute `"${_CLIPBOARD_CMD[@]}"`.
Do not select `wl-copy` solely because it is installed.

- [x] **Step 3: Refactor `cb` to reuse the resolver.**

Use `_clipboard_command copy` for the normal clipboard path. Preserve the
existing handling of zero arguments, one or more files, text arguments, and
OSC52 fallback. Avoid recursion by ensuring the resolver's platform fallback
does not resolve to the Bash `pbcopy` wrapper.

- [x] **Step 4: Run the isolated tests.**

Run:

```bash
bash tests/bash_clipboard_test.sh
```

Expected: PASS for X11 selection, invalid Wayland socket fallback, no-backend
diagnostic, syntax, and `cb` delegation.

### Task 3: Validate the live shell without touching tmux/i3

**Files:**
- No additional files.

- [x] **Step 1: Validate the active X11 backend.**

Run:

```bash
bash -ic 'printf "DISPLAY=%s WAYLAND_DISPLAY=%s\\n" "$DISPLAY" "$WAYLAND_DISPLAY"; _clipboard_command copy; declare -p _CLIPBOARD_CMD; type pbcopy pbpaste cb'
```

Expected: `xclip -selection clipboard` is selected for copy, and all three
public commands exist as functions.

- [x] **Step 2: Exercise copy/paste with a unique token.**

Run:

```bash
token="BASH-CLIP-$(date +%s)"
bash -ic 'printf "%s" "$1" | pbcopy' bash "$token"
bash -ic 'pbpaste'
```

Expected: the second command returns the token. Keep copy and paste in
separate shells because xclip's selection-owner process may retain inherited
pipe descriptors when both operations run inside one command substitution.

- [x] **Step 3: Check reload idempotence and scope.**

Source `.bashrc` twice in one interactive shell and verify the resolver and
wrappers remain functions, then run `git diff --check` and confirm no files
under `stow/tmux` or `stow/i3` changed.

- [x] **Step 4: Commit the implementation.**

```bash
git add stow/bash/.bashrc stow/bash/.bash_lib/nav.sh tests/bash_clipboard_test.sh
git commit -m "fix(bash): select clipboard backend by active protocol"
```
