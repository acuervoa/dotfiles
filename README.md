# Dotfiles · Arch Linux · Entorno de trabajo

Daily-driver dotfiles para **Arch Linux** que alinean i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom y polybar bajo el tema Catppuccin Mocha. El objetivo es mantener **rendimiento**, **atajos consistentes** (tmux/i3/NeoVim), **estética homogénea** y **cambios reversibles** con backups automáticos.

**Highlights**

- Scripts reproducibles (`scripts/bootstrap.sh`, `scripts/rollback.sh`) con backups timestamp + manifests.
- Librería Bash modular (`bash/bash_lib/*.sh`) + helpers CLI (fzf, ripgrep, zoxide, docker, tmux…).
- Configuración de NeoVim (≥0.11) con lazy.nvim, Mason v2, LSP/DAP, formateo (conform.nvim) y tooling dev (git, telescope, overseer, toggleterm…).
- tmux (`tmux/tmux.conf`) con prefix `Ctrl+s`, TPM, integración con NeoVim y scripts auxiliares (`tmux/tmux/scripts/*`).
- Stack gráfico: i3 + polybar + picom + dunst + rofi + kitty tematizados (Catppuccin) y scripts para micrófono/volumen/animaciones.
- Git centralizado (`git/gitconfig`, `git/gitalias`, `git/git-hooks/*`), UI TUI (`config/lazygit/`) + fallback Vim (`vim/`) y plantilla ADR (`.adr/ADR-TEMPLATE.md`).
- Documentación bilingüe (README, SHORTCUTS) con equivalencia de atajos i3 ↔ tmux ↔ NeoVim ↔ kitty ↔ polybar.

---

## Bootstrap, Backups & Rollback

### Requisitos

- GNU stow (`sudo pacman -S stow`).
- Paquetes base recomendados (ver `README-BOOTSTRAP.md`): `git stow bash fzf ripgrep fd bat eza zoxide wl-clipboard xclip trash-cli docker docker-compose bc tmux neovim i3-wm kitty rofi polybar dunst picom`.

### Bootstrap (dry-run)

```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh --dry-run
```

### Bootstrap (aplicar)

```bash
# DOTFILES apunta al repo (por defecto ~/dotfiles)
bash ./scripts/bootstrap.sh
```

Acciones (modo `stow`, por defecto):

- Crea backup en `.backups/<TS>/` y manifest en `.manifests/<TS>.manifest`.
- Enlaza explícitamente Bash (`bashrc`, `bash_profile`, `bash_aliases`, `bash_functions`, `bash_lib`), Git (`gitconfig`, `gitalias`, `git-hooks`), tmux (`tmux.conf`, `tmux/`), Vim (`vimrc`, `vim/`).
- Stow de `config/{dunst,i3,kitty,lazygit,nvim,picom,polybar,rofi}` sobre `~/.config`. Personaliza con `--packages=kitty,polybar`.
- Acepta `DOTFILES=/otra/ruta ./scripts/bootstrap.sh` para entornos compartidos.

Manifiesto (`.manifests/<TS>.manifest`) registra los symlinks aplicados (`LINK src -> dest`) y la lista de paquetes stoweados.

### Plan B (si no usas scripts)

> Requiere stow (`sudo pacman -S stow`). Ejecuta los comandos desde la raíz del repo.

```bash
# Bash / Git / tmux / Vim al $HOME
for f in bash/bashrc bash/bash_profile bash/profile bash/xprofile bash/bash_aliases bash/bash_functions; do
  base=$(basename "$f"); [ -f "$HOME/.${base}" ] && cp -a "$HOME/.${base}" "$HOME/.${base}.bak"
  ln -sfn "$PWD/$f" "$HOME/.${base}"
done
ln -sfn "$PWD/bash/bash_lib" "$HOME/.bash_lib"
ln -sfn "$PWD/git/gitconfig" "$HOME/.gitconfig"
ln -sfn "$PWD/git/gitalias" "$HOME/.gitalias"
ln -sfn "$PWD/git/git-hooks" "$HOME/.git-hooks"
ln -sfn "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$PWD/tmux/tmux" "$HOME/.tmux"
ln -sfn "$PWD/vim/vimrc" "$HOME/.vimrc"
ln -sfn "$PWD/vim/vim" "$HOME/.vim"

# Config bajo ~/.config (stow por paquete)
for pkg in dunst i3 kitty lazygit nvim picom polybar rofi; do
  mkdir -p "$HOME/.config/$pkg"
  stow -vt "$HOME/.config" "config/$pkg" -S
done
```

### Validación (bootstrap)

```bash
for p in ~/.config/{kitty/kitty.conf,lazygit/config.yml,polybar/config.ini,picom/picom.conf,i3/config,dunst/dunstrc,rofi/config.rasi,nvim}; do
  [ -L "$p" ] && echo "OK $p -> $(readlink -f "$p")" || echo "MISSING $p"
done
```

### Rollback (último)

```bash
bash ./scripts/rollback.sh latest
```

- Lee el último manifest, aplica `stow -D` sobre los paquetes listados y borra los symlinks registrados.
- Restaura el backup (`rsync -a .backups/<TS>/ $HOME/`).

Rollback por timestamp:

```bash
bash ./scripts/rollback.sh 20251020-120000
```

### Modo alternativo: git bare

Documentado en `bootstrap.sh --mode=bare`. No aplica symlinks; útil si quieres versionar `$HOME` directamente.

---

## Español

### Resumen

Dotfiles listos para uso diario en **Arch Linux** con i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom, polybar y lazygit. Incluye scripts de bootstrap/rollback, librería Bash modular, configuración completa de NeoVim con LSP/DAP, TPM para tmux y tooling adicional (Git hooks, ADR template, docs de atajos).

### Requisitos (paquetes Arch)

- Base gráfica: `i3-wm`, `polybar`, `picom`, `dunst`, `rofi`, `kitty`.
- Terminal/productividad: `tmux`, `neovim>=0.11`, `vim` (opcional), `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `wl-clipboard`, `xclip`, `trash-cli`, `docker`, `docker-compose`, `bc`, `lazygit`.
- Audio/UX: `pamixer`, `playerctl`, `brightnessctl`, `pacman-contrib` (`checkupdates`), `bluez`, `bluez-utils` (para módulo Bluetooth).
- Fuentes: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_.

> **Animaciones (picom):** si tu build no soporta animaciones, pon `animations = false` en `~/.config/picom/picom.conf` o usa `config/picom/picom-lowlatency.conf`.
> **Ctrl+S (tmux):** añade `stty -ixon` a `~/.bashrc` para liberar `Ctrl+s` (desactiva XON/XOFF).

### Estructura del repo

```
dotfiles/
├── .adr/                 # Plantilla ADR (ADR-TEMPLATE.md)
├── bash/                 # bashrc, aliases, profile, xprofile, librería (~/.bash_lib)
├── config/               # Configs para kitty, lazygit, polybar, picom, i3, dunst, rofi, nvim
│   ├── dunst/            # dunstrc + scripts micctl/volctl + paleta mocha
│   ├── i3/               # config + scripts (i3lock, i3exit, toggle_scratch*, mode_system)
│   ├── kitty/            # kitty.conf (Catppuccin Mocha)
│   ├── lazygit/          # config.yml alineado con ramas principales + hooks globales
│   ├── nvim/             # init.lua + lua/config + lua/plugins (lazy.nvim)
│   ├── picom/            # picom.conf, perfil lowlatency, toggle-animations.sh
│   ├── polybar/          # config.ini, mocha.ini, launch.sh, validate.sh
│   └── rofi/             # config.rasi + grid.rasi
├── git/                  # gitconfig, gitalias, git-hooks (pre-commit, commit-msg)
├── scripts/              # bootstrap.sh, rollback.sh (backups/manifests)
├── tmux/                 # tmux.conf + scripts/ auxiliares
├── vim/                  # vimrc + configuración opcional (~/.vim)
├── README-BOOTSTRAP.md   # Guía rápida paquetes + bootstrap
├── SHORTCUTS.md          # Paridad de atajos i3 ↔ tmux ↔ NeoVim ↔ kitty ↔ polybar
└── CHANGELOG.md / LICENSE / CONTRIBUTING.md
```

### Componentes destacados

- **Bash (`bash/bash_lib/*.sh`)**: módulos `core`, `git`, `nav`, `docker`, `misc` cargables desde `.bashrc`. Atajos útiles (`fo`, `rgf`, `cdf`, `grt`, `docps`, `dlogs`, `dsh`, `fkill`, `cb`, `todo`, etc.).
- **Git**: `git/gitconfig` con alias globales (`git/gitalias`) y hooks centralizados (`git/git-hooks/pre-commit`, `commit-msg`). El bootstrap enlaza `~/.git-hooks` para uso global.
- **Lazygit (`config/lazygit/config.yml`)**: respeta `core.hooksPath` global (`~/.git-hooks`), fija `origin` como remoto principal y reconoce `main`/`master` para operaciones seguras.
- **tmux (`tmux/tmux.conf`)**: prefix `Ctrl+s`, navegación `Alt+h/j/k/l`, splits en cwd, zoom, sync panes, fallback `select-pane` con soporte NeoVim (`christoomey/vim-tmux-navigator`). Plugins TPM (`tmux-resurrect`, `tmux-continuum`, `tmux-fzf`, `tmux-menus`, `tmux-sessionx`, `extrakto`, `tmux-yank`). Scripts auxiliares en `tmux/tmux/scripts/*` (CPU, memoria, estado paneles) para statusline.
- **NeoVim (`config/nvim/`)**: `init.lua` carga `lua/config/*` (opciones, keymaps, autocmds, lazy.nvim). Plugins categorizados (`lua/plugins/`):
  - LSP vía `mason-org/mason.nvim` + `mason-lspconfig` + API nativa 0.11 (`intelephense`, `lua_ls`, `ts_ls`, `html`, `cssls`, `jsonls`) con breadcrumbs (`outline.nvim`, `barbecue`), inlay hints y diagnostics personalizados.
  - Autocompletado (`cmp.nvim`), Treesitter, Telescope, Neo-tree, git (`gitsigns`, `lazygit`), formateo (`conform.nvim`), lint (`nvim-lint`), tareas (`overseer.nvim`), DAP (`nvim-dap`, `dap-ui`, `mason-nvim-dap` con preset Xdebug), which-key, toggleterm, trouble, notify, bufferline, lualine, indent guides, VSCode theme.
  - Comandos útiles: `:Lazy! sync`, `:Mason`, `:Neotree`, `:OverseerRun`, `:Trouble`, `:FormatToggle`.
- **i3 (`config/i3/config`)**: paridad de atajos con tmux/NeoVim (`$mod+Ctrl+hjkl`), scratchpads (kitty, Obsidian), scripts `toggle_scratch.sh`, `mode_system.sh`, `i3lock.sh`. Integración con `playerctl`, `pamixer`, `brightnessctl`, `dunstctl`.
- **Polybar (`config/polybar/`)**: barra principal + secundaria, módulo de actualizaciones (`updates-pacman-aurhelper`), notificaciones (`dunst`), micrófono (`micctl`), bluetooth, monitors variables (`${env:MONITOR}`), script `launch.sh` para reiniciar barras, paleta `mocha.ini`.
- **Picom (`config/picom/`)**: perfil completo (animaciones blur) y `picom-lowlatency.conf` sin animaciones. Script `toggle-animations.sh` habilita/desactiva animaciones con backup automático y relanza picom.
- **Dunst (`config/dunst/`)**: `dunstrc` + tema Catppuccin (`mocha.conf`) + scripts `micctl`/`volctl` para polybar/i3.
- **Rofi (`config/rofi/`)**: `config.rasi` y layout `grid.rasi` coherentes con Catppuccin.
- **Kitty (`config/kitty/kitty.conf`)**: Catppuccin Mocha, ligaduras, copy-on-select, integración con tmux/i3.
- **Docs**: `SHORTCUTS.md` documenta atajos bilingües; `README-BOOTSTRAP.md` resume paquetes y bootstrap; `CHANGELOG.md` seguimiento histórico; `.adr/` facilita decisiones arquitectónicas.
- **Fallback Vim (`vim/`)**: `vimrc` y `vim/coc-settings.json` para entornos donde NeoVim no esté disponible.

### Instalación segura (resumen manual)

```bash
cd ~
git clone <URL_DE_TU_REPO> dotfiles
cd ~/dotfiles
bash ./scripts/bootstrap.sh
```

Para enlaces mínimos manuales:

```bash
mkdir -p ~/.config/{kitty,lazygit,polybar,picom,i3,dunst,rofi}
for f in kitty/kitty.conf lazygit/config.yml polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f" ] && mv "$HOME/.config/$f"{,.bak}
  ln -sf "$HOME/dotfiles/config/$f" "$HOME/.config/$f"
done
[ -e ~/.config/nvim ] && mv ~/.config/nvim{,.bak}
ln -s ~/dotfiles/config/nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

### Monitores (polybar)

Config soporta `${env:MONITOR:eDP-1}` y `${env:MONITOR2:DP-1}`. Ejemplo:

```bash
MONITOR=eDP-1 MONITOR2=DP-1 polybar -r main &
```

### Perfiles picom

```bash
# Completo (blur + animaciones)
picom --config ~/.config/picom/picom.conf -b
# Bajo retardo (sin animaciones)
picom --config ~/.config/picom/picom-lowlatency.conf -b
```

Alterna animaciones:

```bash
~/.config/picom/toggle-animations.sh on
~/.config/picom/toggle-animations.sh off
```

### Validación rápida

```bash
kitty --version
pkill -x polybar 2>/dev/null; MONITOR=${MONITOR:-eDP-1} polybar main &
pkill -x picom 2>/dev/null; picom --config ~/.config/picom/picom.conf
notify-send "Prueba" "Dunst OK" && dunstctl is-paused
nvim --headless "+checkhealth" +qa
tmux -V
```

Esperado: Polybar visible; picom con sombras/animaciones según perfil; notificación de dunst; `:checkhealth` sin errores críticos; `Ctrl+s` usable como prefix tmux.

### Rollback manual (sin script)

```bash
find ~/.config -maxdepth 2 -type l -lname "$HOME/dotfiles/*" -exec rm -f {} \;
[ -f ~/.bashrc.bak ] && mv -f ~/.bashrc{.bak,}
[ -d ~/.config/nvim.bak ] && rm -rf ~/.config/nvim && mv ~/.config/nvim{.bak,}
for f in kitty/kitty.conf polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f.bak" ] && mv -f "$HOME/.config/$f"{.bak,}
done
```

### Hooks de Git (reproducibles)

Bootstrap enlaza `git/git-hooks` → `~/.git-hooks`. Para configurarlo manualmente:

```bash
mkdir -p ~/.git-hooks
cp -f ./git/git-hooks/pre-commit ~/.git-hooks/pre-commit
cp -f ./git/git-hooks/commit-msg ~/.git-hooks/commit-msg
chmod +x ~/.git-hooks/{pre-commit,commit-msg}
git config --global core.hooksPath "$HOME/.git-hooks"
```

- **pre-commit**: bloquea trazas (`console.log`, `var_dump`, etc.) y ficheros sensibles (`.env*`, `docker-compose.override.yml`).
- **commit-msg**: rechaza mensajes con `WIP`, `tmp`, etc.

Consejos: para cambios rápidos usa `git clean` helpers (`gclean`, `gundo`, `wip`, `fixup`) + `git rebase -i --autosquash`.

### Licencia

[MIT](LICENSE)

---

## English

### Overview

Daily-driver dotfiles for **Arch Linux** featuring i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom and polybar under a unified Catppuccin Mocha theme. Includes bootstrap/rollback scripts with backups, a modular Bash library, full NeoVim setup (lazy.nvim + Mason + LSP/DAP), tmux with TPM, Git tooling and bilingual shortcut docs.

### Requirements (Arch packages)

- UI stack: `i3-wm`, `polybar`, `picom`, `dunst`, `rofi`, `kitty`.
- Terminal/productivity: `tmux`, `neovim>=0.11`, `vim` (optional), `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `wl-clipboard`, `xclip`, `trash-cli`, `docker`, `docker-compose`, `bc`, `lazygit`.
- Audio/UX: `pamixer`, `playerctl`, `brightnessctl`, `pacman-contrib`, `bluez`, `bluez-utils`.
- Fonts: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_.

> **Picom animations:** set `animations = false` or use `picom-lowlatency.conf` if your build lacks animation support.
> **tmux Ctrl+S:** append `stty -ixon` to `~/.bashrc` to free `Ctrl+s` (disables XON/XOFF).

### Repository layout

```
dotfiles/
├── .adr/                 # ADR template
├── bash/                 # shell rc, aliases, profile, modular library (~/.bash_lib)
├── config/               # kitty, lazygit, polybar, picom, i3, dunst, rofi, nvim configs
├── git/                  # gitconfig, gitalias, reusable hooks
├── scripts/              # bootstrap.sh, rollback.sh
├── tmux/                 # tmux.conf + helper scripts
├── vim/                  # vim fallback configuration
├── README-BOOTSTRAP.md   # quick bootstrap guide
├── SHORTCUTS.md          # shortcut parity (i3 ↔ tmux ↔ NeoVim ↔ kitty ↔ polybar)
└── Docs: CHANGELOG.md, LICENSE, CONTRIBUTING.md
```

### Key components

- **Bash library:** `bash/bash_lib/{core,git,nav,docker,misc}.sh` exposes helpers (`fo`, `rgf`, `cdf`, `grt`, `docps`, `dlogs`, `dsh`, `fkill`, `cb`, `todo`, …). Load them conditionally from `.bashrc`.
- **Git tooling:** opinionated `gitconfig` + global aliases (`gitalias`) + reproducible hooks (`git/git-hooks`). Bootstrap links them into `~/.gitconfig`, `~/.gitalias`, `~/.git-hooks`.
- **Lazygit:** `config/lazygit/config.yml` honours the global hooks path, keeps `origin` as main remote and recognises `main`/`master` as trunk branches for safe sync.
- **tmux:** `Ctrl+s` prefix, navigation with `Alt+h/j/k/l`, splits in current working dir, zoom + pane sync, NeoVim-aware navigation. TPM plugins: sensible, yank, resurrect, continuum, vim-tmux-navigator, tmux-fzf, tmux-menus, tmux-sessionx, extrakto. Extra scripts in `tmux/tmux/scripts/` feed the status line.
- **NeoVim:** `config/nvim/` runs lazy.nvim, Mason (v2), LSP (intelephense, lua_ls, ts_ls, html, cssls, jsonls), cmp, Treesitter, Telescope, Neo-tree, git UI, conform.nvim + nvim-lint, overseer tasks, nvim-dap (+ UI/virtual text + Mason integration), VSCode-style UI (bufferline, lualine, notify, toggleterm, trouble, indent guides, barbecue). Handy commands: `:Lazy! sync`, `:Mason`, `:OverseerRun`, `:Trouble`, `:FormatToggle`.
- **i3 & UX:** `config/i3/config` mirrors tmux/NeoVim bindings, provides scratchpads (kitty, Obsidian), system mode, locker script, multimedia controls (playerctl, pamixer, micctl, volctl, brightnessctl) and integrates with dunst/picom.
- **Polybar:** Catppuccin-themed bars (`config/polybar/config.ini`, `mocha.ini`) with modules for workspaces, notifications, bluetooth, pacman updates, filesystem, audio, network and dual-monitor support via `MONITOR` variables. `config/polybar/launch.sh` restarts both bars.
- **Picom:** main config with blur/animations + low-latency profile. `toggle-animations.sh` toggles animation blocks, keeps backups and relaunches picom.
- **Dunst:** themed `dunstrc`, palette `mocha.conf`, scripts `micctl`/`volctl` used from i3/polybar.
- **Rofi:** Catppuccin `config.rasi` + grid layout.
- **Kitty:** Catppuccin config with copy-on-select, ligatures, tmux-friendly tweaks.
- **Docs & ADR:** `SHORTCUTS.md` bilingual shortcuts, `README-BOOTSTRAP.md` quick setup, `.adr/ADR-TEMPLATE.md` for architecture decisions.
- **Vim fallback:** `vim/vimrc` + `vim/vim/coc-settings.json` for systems where only Vim is available.

### Safe install (manual quick start)

```bash
cd ~ && git clone <YOUR_REPO_URL> dotfiles
cd ~/dotfiles
bash ./scripts/bootstrap.sh
```

Minimal manual symlinks:

```bash
mkdir -p ~/.config/{kitty,lazygit,polybar,picom,i3,dunst,rofi}
for f in kitty/kitty.conf lazygit/config.yml polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f" ] && mv "$HOME/.config/$f"{,.bak}
  ln -sf "$HOME/dotfiles/config/$f" "$HOME/.config/$f"
done
[ -e ~/.config/nvim ] && mv ~/.config/nvim{,.bak}
ln -s ~/dotfiles/config/nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

### Polybar monitors

```bash
MONITOR=eDP-1 MONITOR2=DP-1 polybar -r main &
```

### Picom profiles

```bash
picom --config ~/.config/picom/picom.conf -b
picom --config ~/.config/picom/picom-lowlatency.conf -b
# Toggle animations on demand
~/.config/picom/toggle-animations.sh on
~/.config/picom/toggle-animations.sh off
```

### Validation

```bash
kitty --version
pkill -x polybar 2>/dev/null; MONITOR=${MONITOR:-eDP-1} polybar main &
pkill -x picom 2>/dev/null; picom --config ~/.config/picom/picom.conf
notify-send "Test" "Dunst OK" && dunstctl is-paused
nvim --headless "+checkhealth" +qa
tmux -V
```

Expected: visible polybar, picom blur/animations (or low latency), working dunst notification, `:checkhealth` without critical errors, `Ctrl+s` available as tmux prefix.

### Rollback

```bash
bash ./scripts/rollback.sh latest
```

Or choose a timestamp manifest (see `.manifests/`). Manual fallback instructions mirror the Spanish section.

### Git hooks

```bash
mkdir -p ~/.git-hooks
cp -f ./git/git-hooks/pre-commit ~/.git-hooks/pre-commit
cp -f ./git/git-hooks/commit-msg ~/.git-hooks/commit-msg
chmod +x ~/.git-hooks/{pre-commit,commit-msg}
git config --global core.hooksPath "$HOME/.git-hooks"
```

- **pre-commit:** blocks debug traces (`console.log`, `var_dump`, …) and sensitive files (`.env*`, `docker-compose.override.yml`).
- **commit-msg:** rejects messages containing `WIP`, `tmp`, …

### License

[MIT](LICENSE)
