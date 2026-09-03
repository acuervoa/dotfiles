# Herramientas instaladas

Generado desde `scripts/audit-application-ownership.sh` — no editar a mano.

Disponibilidad: ✅ instalada · 🔴 falta el binario.

| Herramienta | Binario | Uso | Config versionada |
| --- | --- | --- | --- |
| **Kitty** ✅ | `kitty` | terminal transport | `stow/kitty/.config/kitty/kitty.conf` |
| **Rofi** ✅ | `rofi` | visual selector | `stow/rofi/.config/rofi/config.rasi` |
| **Albert** ✅ | `albert` | secondary launcher under review | `stow/albert/.config/albert/config` |
| **Dunst** ✅ | `dunst` | notifications | `stow/dunst/.config/dunst/dunstrc` |
| **Polybar** ✅ | `polybar` | persistent status | `stow/polybar/.config/polybar/config.ini` |
| **CopyQ** ✅ | `copyq` | clipboard history | `stow/copyq/.config/copyq/copyq.conf` |
| **clipmenu** ✅ | `clipmenu` | clipboard history selector | `stow/i3/.config/i3/config` |
| **ble.sh** ✅ | `/usr/share/blesh/ble.sh` | line editing | `stow/blesh/.config/blesh/blerc` |
| **Atuin** ✅ | `atuin` | history backend | `stow/atuin/.config/atuin/config.toml` |
| **FZF** ✅ | `fzf` | text selection | `stow/bash/.bashrc` |
| **Starship** ✅ | `starship` | prompt | `stow/bash/.bashrc` |
| **zoxide** ✅ | `zoxide` | directory navigation | `stow/bash/.bashrc` |
| **direnv** ✅ | `direnv` | project environment | `stow/bash/.bashrc` |
| **mise** ✅ | `mise` | runtime/tool versions | `stow/mise/.config/mise/config.toml` |
| **fnm** ✅ | `fnm` | Node runtime | `stow/bash/.bashrc` |
| **LazyGit** ✅ | `lazygit` | Git visual | `stow/lazygit/.config/lazygit/config.yml` |
| **Yazi** ✅ | `yazi` | filesystem navigation | `stow/yazi/.config/yazi/yazi.toml` |
| **lnav** ✅ | `lnav` | log analysis | `stow/lnav` |
| **btop** ✅ | `btop` | system monitoring | `stow/btop/.config/btop/btop.conf` |
| **Neovim** ✅ | `nvim` | editor and code workflows | `stow/nvim/.config/nvim/init.lua` |
| **cava** ✅ | `cava` | audio visualizer | `stow/cava/.config/cava/config` |
| **delta** ✅ | `delta` | git diff pager | `stow/git/.gitconfig` |
| **gh-dash** ✅ | `gh` | GitHub PR/issue TUI dashboard | `stow/gh-dash/.config/gh-dash/config.yml` |
| **gitleaks** ✅ | `gitleaks` | secret scanning (entropy + rules) | `scripts/check-secrets.sh` |
| **difftastic** ✅ | `difft` | structural diff, alias gdt | `stow/bash/.bash_aliases` |
| **ripgrep-all** 🔴 | `rga` | content search in PDFs/docs, function rgaf | `stow/bash/.bash_lib/nav.sh` |

## Ownership por capacidad

Una sola herramienta por capacidad — ver `docs/audits/2026-09-02-application-integration.md` para el razonamiento.

| Capacidad | Owner |
| --- | --- |
| launcher | **Rofi** |
| history | **Atuin** |
| clipboard-history | **clipmenu** |
| prompt | **Starship** |
| panes | **tmux** |
| windows | **i3** |
| editor | **Neovim** |
| git-visual | **LazyGit** |
| notifications | **Dunst** |
