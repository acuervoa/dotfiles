# Practical Environment Guide

This progressive guide teaches the environment through repeatable workflows
instead of a disconnected shortcut list. Every layer has an owner, and you
keep the same project context while moving through the work.

## Mental model

| Context | Owner | What you do there |
|---|---|---|
| i3 | i3 | Workspaces and applications |
| Kitty | Kitty | Keyboard, terminal and clipboard transport |
| tmux | tmux | Sessions, windows and panes |
| Bash/ble.sh | Bash/ble.sh | Commands and line editing |
| Neovim | Neovim | Code, LSP and tasks |
| Rofi | Rofi | Visual selections |
| clipmenu | clipmenu | Visual clipboard history |
| LazyGit | LazyGit | Git review |
| Polybar/Dunst | Polybar/Dunst | State and notifications |

`$mod` belongs to i3, `C-s` is the tmux prefix, `<leader>` is Space inside
Neovim, and `C-r` searches Atuin in Bash. `p/r/y/n/z` keep their native Vim
meaning; in Bash they are contextual commands.

## Startup

The startup sequence is:

```text
i3 $mod+Return → Kitty → tmux
```

tmux uses `C-s` as its prefix: press `C-s`, then press the action.

- `$mod+d`: Rofi application selector.
- `$mod+f`: Rofi window selector.
- `$mod+v`: clipboard history through clipmenu/Rofi.
- `$mod+y`: Dunst notification history.
- `C-s ?`: tmux help.

In selectors, `Enter` confirms and `Escape` cancels. Kitty transports the
keystroke; tmux decides which pane or window receives the action.

## Backend workflow

### Open the context

From Bash:

```bash
tproj project-name
```

This recovers the `proj-project-name` session or creates development, shell and
logs windows. To use the current repository or create a full layout:

```bash
dev
dev /path/to/project
```

The goal is a stable tmux context, not a collection of loose terminals.

### Edit and validate

In the Neovim pane:

1. `<C-p>` or `<leader>ff`: find a file.
2. `<leader>fg`: search project text.
3. `C-h/j/k/l`: move focus between splits and panes.
4. `gd` and `K`: navigate with LSP.
5. `<leader>pt` or `<leader>pT`: run the nearest or current-file test.
6. `<leader>pf`: format; `<leader>pl`: run lint.
7. `<leader>po`: choose an Overseer task.

`<leader>` means Space; `<leader>pt` is `Space p t`. Editor, shell and logs
should remain in the same project.

## History, clipboard and selectors

- `C-r` in Bash searches command history in Atuin.
- FZF filters and selects in wrappers such as `proj`, `fo`, `cdf` and `gbr`.
- Rofi handles graphical i3 selections.
- clipmenu owns visual history; `xsel`, `xclip`, `wl-copy` and Kitty are
  transport, not history managers.
- `Ctrl+Shift+C` and `Ctrl+Shift+V` copy and paste in Kitty.
- `cb` copies text from Bash through the available backend.

If you choose nothing, press `Escape`: an empty selection must not change
directory or run an action.

## Git

The three entrypoints open the same visual owner, LazyGit:

- `lg` from Bash.
- `C-s g` from tmux.
- `<leader>gg` from Neovim.

Use the entrypoint for your current context. For small changes use Gitsigns
(`]c`, `[c`, `<leader>hp`); for state, staging and history open LazyGit.

## Logs

In the project shell pane:

```bash
dlogs
```

Select a Docker Compose service and follow its logs. Use `lnav` when installed
for advanced inspection. The `dev` layout can keep logs in a dedicated pane;
do not use that pane for migrations or deployments.

## Monitoring

`C-s b` opens btop in a tmux popup. Polybar shows the persistent desktop
summary and Dunst reports events without blocking the work.

## Closing and recovery

- `Escape`: cancel a selector.
- `<leader>q` in Neovim: close the current window.
- `C-s q` in tmux: confirm closing a pane.
- `$mod+q` in i3: confirm closing a window/application.
- `C-s ?`: consult help again.

If something closes by mistake, `tproj project-name` recovers the context.

## Exercises

### Exercise 1: edit and validate

**Start:** an existing project is available in `~/Workspace`.

1. Run `tproj project-name`.
2. Press `<leader>ff` and open a backend file.
3. Edit one line and save with `<leader>w`.
4. Run `<leader>pt`.
5. If it passes, run `<leader>pf`.

**Expected end:** you remain in the same project and tmux session.

### Exercise 2: review Git

**Start:** the project is open with known local changes.

1. Run `lg` or press `C-s g`.
2. Review state and diff without confirming unwanted operations.
3. Exit the popup using LazyGit's indicated key.
4. Return to Neovim with `<leader>gg` only if another review is needed.

**Expected end:** you understand pending changes without altering history.

### Exercise 3: observe and close

**Start:** services or processes are active.

1. Run `dlogs` and select a service.
2. Open btop with `C-s b`.
3. Cancel selectors with `Escape` and close the btop popup.
4. Use `C-s q` to close one temporary pane and confirm consciously.

**Expected end:** the editor and primary shell remain open.

## Fallbacks

| Missing | Alternative |
|---|---|
| FZF | Explicit command or `Escape` to cancel |
| Docker Compose | Inspect available local logs |
| LazyGit | `git status`, `git diff` and `git log` |
| Yazi | `fo`, `cdf` or explicit `cd` |
| lnav | `less` or direct stream |
| btop | `topme` or `ps` |

## References

- [Global shortcuts](../SHORTCUTS.md)
- [Neovim shortcuts](../stow/nvim/.config/nvim/SHORTCUTS.md)
- [Neovim usage](../stow/nvim/.config/nvim/USAGE.md)
- [Neovim workflow](audits/2026-09-01-neovim-workflows.md)
- [Application integration](audits/2026-09-02-application-integration.md)
- [Bash workflows](bash-workflows.md)
- [Bash muscle memory](bash-muscle-memory.md)
