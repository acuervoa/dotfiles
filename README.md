# Dotfiles · Arch Linux · Entorno de trabajo

Repositorio de uso diario para **Arch Linux** orientado a productividad: i3 + tmux + NeoVim, kitty, rofi, dunst, picom y polybar bajo el tema **Catppuccin Mocha**. La filosofía es mantener **rendimiento**, **estética homogénea**, **atajos consistentes** y **cambios reversibles** mediante scripts de bootstrap/rollback.

![stack](https://img.shields.io/badge/i3-4.23-blue?style=flat-square) ![tmux](https://img.shields.io/badge/tmux-3.4-green?style=flat-square) ![neovim](https://img.shields.io/badge/NeoVim-%3E%3D0.11-57A143?style=flat-square) ![license](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)

---

## Tabla de contenidos

1. [Pila y highlights](#pila-y-highlights)
2. [Estructura del repositorio](#estructura-del-repositorio)
3. [Requisitos](#requisitos)
4. [Bootstrap](#bootstrap)
5. [Rollback](#rollback)
6. [Modo alternativo (git bare)](#modo-alternativo-git-bare)
7. [Componentes principales](#componentes-principales)
8. [Validaciones rápidas](#validaciones-rápidas)
9. [Licencia](#licencia)

---

## Pila y highlights

- **Bootstrap reproducible** mediante `scripts/bootstrap.sh` con backups timestamp en `.backups/<TS>` y manifiestos en `.manifests/<TS>.manifest`.
- **Rollback automático**: `scripts/rollback.sh <timestamp|latest>` deshace symlinks y restaura backups.
- **Librería Bash modular** (`bash/bash_lib/*.sh`) con helpers para git, docker, navegación y productividad (`cb`, `rgf`, `grt`, `fo`, `docps`, etc.).
- **NeoVim** (≥0.11) con lazy.nvim, Mason v2, Treesitter, LSP/DAP, conform.nvim + nvim-lint, Overseer y tooling git/telescope.
- **tmux** con prefix `Ctrl+s`, integración NeoVim (vim-tmux-navigator), TPM (resurrect, continuum, menus, fzf, extrakto) y scripts personalizados.
- **Stack gráfico** tematizado (Catppuccin Mocha): i3, polybar, picom, dunst, rofi, kitty, con scripts para micrófono/volumen/animaciones y scratchpads.
- **Git tooling**: `gitconfig`, `gitalias`, hooks reproducibles (`git/git-hooks/*`), plantilla ADR (`.adr/ADR-TEMPLATE.md`), configuración lazygit (`config/lazygit/`).
- **Documentación bilingüe**: README, `README-BOOTSTRAP.md` (atajo rápido), `SHORTCUTS.md` (equivalencia de atajos i3 ↔ tmux ↔ NeoVim ↔ kitty ↔ polybar).

---

## Estructura del repositorio

```
dotfiles/
├── .adr/                 # Plantilla ADR
├── bash/                 # rc/profile, aliases, funciones y bash_lib
├── config/               # kitty, lazygit, nvim, polybar, picom, i3, dunst, rofi
├── git/                  # gitconfig, gitalias y hooks
├── scripts/              # bootstrap.sh, rollback.sh
├── tmux/                 # tmux.conf + scripts auxiliares
├── vim/                  # fallback para Vim + coc-settings
├── README-BOOTSTRAP.md   # guía exprés
├── SHORTCUTS.md          # atajos bilingües
└── docs: CHANGELOG, CONTRIBUTING, LICENSE
```

---

## Requisitos

1. **Paquetes base** (ver `README-BOOTSTRAP.md` para lista ampliada):
   ```bash
   sudo pacman -S git stow bash fzf ripgrep fd bat eza zoxide wl-clipboard xclip trash-cli docker docker-compose bc tmux neovim i3-wm kitty rofi polybar dunst picom lazygit
   ```
2. **Herramientas opcionales**: `playerctl`, `pamixer`, `brightnessctl`, `obsidian`, `wl-copy`, `pbcopy`.
3. **Gnu Stow** es obligatorio para los scripts (aunque se puede ejecutar manualmente sin él, ver plan B abajo).

---

## Bootstrap

### 1. Dry-run
```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh --dry-run
```

### 2. Aplicar cambios
```bash
# DOTFILES apunta al repo (por defecto ~/dotfiles)
bash ./scripts/bootstrap.sh
```

#### ¿Qué hace?

- Genera backup en `.backups/<TS>/` y manifest en `.manifests/<TS>.manifest`.
- Stow por paquetes (`bash`, `git`, `tmux`, `vim`, `config/{kitty,lazygit,nvim,polybar,picom,i3,dunst,rofi}`) sobre `$HOME`/`~/.config`.
- Acepta `--packages=kitty,polybar` para aplicar sólo subconjuntos.
- Permite `DOTFILES=/otra/ruta ./scripts/bootstrap.sh` para entornos compartidos.

### Plan B (manual, sin scripts)

```bash
# Bash / Git / tmux / Vim hacia $HOME
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

# Config bajo ~/.config
for pkg in dunst i3 kitty lazygit nvim picom polybar rofi; do
  mkdir -p "$HOME/.config/$pkg"
  stow -vt "$HOME/.config" "config/$pkg" -S
done
```

---

## Rollback

```bash
# Último manifest
bash ./scripts/rollback.sh latest

# Rollback por timestamp
bash ./scripts/rollback.sh 20251020-120000
```

- Lee el manifest correspondiente, ejecuta `stow -D` y elimina symlinks listados.
- Restaura backup con `rsync -a .backups/<TS>/ $HOME/`.

---

## Modo alternativo (git bare)

`bootstrap.sh --mode=bare` documenta la variante para versionar `$HOME` vía `git --bare` (sin symlinks). Útil para máquinas donde no quieres stow.

---

## Componentes principales

- **Bash library**: `bash/bash_lib/{core,git,nav,docker,misc}.sh` expone helpers (`fo`, `rgf`, `cdf`, `grt`, `docps`, `dlogs`, `dsh`, `fkill`, `cb`, `todo`, …). `cb` admite stdin/args, detecta `wl-copy`, `xclip` o `pbcopy` y no añade newline extra.
- **Git tooling**: `git/gitconfig`, `git/gitalias`, hooks (`git/git-hooks/{pre-commit,commit-msg}`) + configuración `config/lazygit/config.yml` que respeta `core.hooksPath` y considera `main/master` como trunk.
- **tmux**: prefix `Ctrl+s`, navegación `Alt+h/j/k/l`, splits en cwd, zoom/pane sync, scripts en `tmux/tmux/scripts/` para status, TPM con sensible, yank, resurrect, continuum, vim-tmux-navigator, tmux-fzf, tmux-menus, tmux-sessionx, extrakto. `Prefix+m` abre menús contextuales.
- **NeoVim**: `config/nvim/` usa lazy.nvim, Mason (v2), LSP (lua_ls, ts_ls, html, cssls, jsonls, intelephense), cmp, Treesitter, Telescope, Neo-tree, git UI, conform.nvim + nvim-lint, overseer, nvim-dap (+ UI/virtual text). Comandos clave: `:Lazy! sync`, `:Mason`, `:OverseerRun`, `:Trouble`, `:FormatToggle`.
- **i3 + UX**: `config/i3/config` alinea bindings con tmux/NeoVim, scratchpads (kitty, Obsidian), modos de sistema, multimedia (playerctl, pamixer, micctl, volctl, brightnessctl) e integración con dunst/picom.
- **Polybar**: config Catppuccin (`config/polybar/config.ini`, `mocha.ini`) con módulos de workspaces, notificaciones, bluetooth, actualizaciones pacman, FS, audio, red; `config/polybar/launch.sh` relanza las barras.
- **Picom**: `config/picom/picom.conf` con blur/animaciones + perfil low-latency; `toggle-animations.sh` gestiona animaciones manteniendo backups y reiniciando picom.
- **Dunst/Rofi/Kitty**: configs Catppuccin (`config/dunst/dunstrc`, `config/rofi/config.rasi`, `config/kitty/kitty.conf`) con scripts `micctl`/`volctl` usados desde i3/polybar.
- **Documentación**: `SHORTCUTS.md` lista atajos equivalentes, `README-BOOTSTRAP.md` resume instalación, `.adr/ADR-TEMPLATE.md` guía decisiones de arquitectura.
- **Vim fallback**: `vim/vimrc` + `vim/vim/coc-settings.json` para entornos sin NeoVim.

---

## Validaciones rápidas

```bash
# Verificar symlinks
for p in ~/.config/{kitty/kitty.conf,lazygit/config.yml,polybar/config.ini,picom/picom.conf,i3/config,dunst/dunstrc,rofi/config.rasi,nvim}; do
  [ -L "$p" ] && echo "OK $p -> $(readlink -f "$p")" || echo "MISSING $p"
done

# Lanzar servicios clave
kitty --version
pkill -x polybar 2>/dev/null; MONITOR=${MONITOR:-eDP-1} polybar -r main &
pkill -x picom 2>/dev/null; picom --config ~/.config/picom/picom.conf
notify-send "Test" "Dunst OK" && dunstctl is-paused
nvim --headless "+checkhealth" +qa
tmux -V
```

Polybar debe aparecer, picom aplicar blur/animaciones (o perfil low-latency), dunst recibir notificación, `:checkhealth` sin errores críticos y `Ctrl+s` como prefix tmux.

### Polybar (monitores múltiples)
```bash
MONITOR=eDP-1 MONITOR2=DP-1 polybar -r main &
```

### Picom (perfiles)
```bash
picom --config ~/.config/picom/picom.conf -b
picom --config ~/.config/picom/picom-lowlatency.conf -b
~/.config/picom/toggle-animations.sh on
~/.config/picom/toggle-animations.sh off
```

### Git hooks manuales
```bash
mkdir -p ~/.git-hooks
cp -f ./git/git-hooks/pre-commit ~/.git-hooks/pre-commit
cp -f ./git/git-hooks/commit-msg ~/.git-hooks/commit-msg
chmod +x ~/.git-hooks/{pre-commit,commit-msg}
git config --global core.hooksPath "$HOME/.git-hooks"
```

---

## Licencia

[MIT](LICENSE)
