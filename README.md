# Arch Linux · Entorno de trabajo (i3 + tmux + (Neo)Vim + kitty + rofi + dunst + picom + polybar)

**ES | EN** · [Español](#español) · [English](#english)

---

## Español

### Resumen

Dotfiles listos para uso diario en **Arch Linux**: i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom y polybar.  
Objetivos: **rendimiento**, **atajos coherentes** (paridad tmux/i3/NeoVim), **estética consistente (Catppuccin Mocha)**, y **cambios reversibles**.

### Requisitos (paquetes Arch)

- i3-wm, polybar, picom, dunst, rofi, kitty, tmux, neovim (≥ 0.11)
- pamixer, pacman-contrib (`checkupdates`), bluez/bluez-utils (si usas el módulo BT)
- Fuentes: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_

> **Nota animaciones (picom):** si tu `picom` no soporta animaciones, desactívalas en `~/.config/picom/picom.conf` (`animations = false`) o usa un build con soporte.

### Estructura (parcial)

```
dotfiles/
├── bash/                 # bashrc, aliases, profile, xprofile...
├── config/
│   ├── dunst/            # dunstrc, scripts (micctl, volctl)
│   ├── i3/               # config + scripts (i3lock, i3exit, toggle_scratch...)
│   ├── kitty/            # kitty.conf (Catppuccin Mocha)
│   ├── nvim/             # init.lua, lua/config/* (lazy.nvim)
│   ├── picom/            # picom.conf (GLX, sombras, blur, animaciones)
│   ├── polybar/          # config.ini + scripts (updates, dunst, mic, bt...)
│   └── rofi/             # config.rasi + temas
├── README.md
├── SHORTCUTS.md
└── CHANGELOG.md
```

### Instalación (segura y reversible)

1. **Clona** en `$HOME`:

```bash
cd ~
git clone <URL_DE_TU_REPO> dotfiles
```

2. **Backups** y **symlinks** (ejemplos mínimos):

```bash
# KITTY
mkdir -p ~/.config/kitty
[ -f ~/.config/kitty/kitty.conf ] && mv ~/.config/kitty/kitty.conf{,.bak}
ln -s ~/dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# POLYBAR
mkdir -p ~/.config/polybar
[ -f ~/.config/polybar/config.ini ] && mv ~/.config/polybar/config.ini{,.bak}
ln -s ~/dotfiles/config/polybar/config.ini ~/.config/polybar/config.ini

# PICOM
mkdir -p ~/.config/picom
[ -f ~/.config/picom/picom.conf ] && mv ~/.config/picom/picom.conf{,.bak}
ln -s ~/dotfiles/config/picom/picom.conf ~/.config/picom/picom.conf

# I3
mkdir -p ~/.config/i3
[ -f ~/.config/i3/config ] && mv ~/.config/i3/config{,.bak}
ln -s ~/dotfiles/config/i3/config ~/.config/i3/config

# DUNST
mkdir -p ~/.config/dunst
[ -f ~/.config/dunst/dunstrc ] && mv ~/.config/dunst/dunstrc{,.bak}
ln -s ~/dotfiles/config/dunst/dunstrc ~/.config/dunst/dunstrc

# ROFI (config y tema)
mkdir -p ~/.config/rofi
[ -f ~/.config/rofi/config.rasi ] && mv ~/.config/rofi/config.rasi{,.bak}
ln -s ~/dotfiles/config/rofi/config.rasi ~/.config/rofi/config.rasi

# NEOVIM (symlink del directorio completo)
[ -e ~/.config/nvim ] && mv ~/.config/nvim{,.bak}
ln -s ~/dotfiles/config/nvim ~/.config/nvim

# BASH (opción A: enlazar)
[ -f ~/.bashrc ] && mv ~/.bashrc{,.bak}
ln -s ~/dotfiles/bash/bashrc ~/.bashrc
ln -sf ~/dotfiles/bash/bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/bash/bash_profile ~/.bash_profile
ln -sf ~/dotfiles/bash/profile ~/.profile
ln -sf ~/dotfiles/bash/xprofile ~/.xprofile

# BASH (opción B: 'source' sin reemplazar archivos)
grep -q 'dotfiles/bash/bashrc' ~/.bashrc 2>/dev/null || echo 'source ~/dotfiles/bash/bashrc' >> ~/.bashrc
```

3. **Bootstrap NeoVim (plugins con lazy.nvim)**:

```bash
nvim --headless "+Lazy! sync" +qa
```

4. **Libera Ctrl+S para tmux** (evita XON/XOFF):

```bash
grep -q 'stty -ixon' ~/.bashrc || echo 'stty -ixon' >> ~/.bashrc
```

### Atajos clave (paridad tmux/i3/NeoVim)

- **tmux**: _Prefix_ = **Ctrl+s**
- **NeoVim**:
  - _Leader_ = **Espacio**; guardar **\<leader>w**
  - Navegación de ventanas **Ctrl+h/j/k/l**
  - Splits rápidos: **\<leader>"** (horizontal), **\<leader>%** (vertical)
  - Redimensionar: **Alt+Shift + flechas** (también **Ctrl+flechas**)
  - Búsqueda: **Ctrl+f** abre `/`
- **kitty**: copiar **Ctrl+Shift+C**, pegar **Ctrl+Shift+V**, nueva tab **Ctrl+Shift+Enter**, abrir URL con **Ctrl+click**
- **polybar** (ejemplos):
  - Mic: click-izq → _mute/unmute_
  - Actualizaciones: click-izq abre terminal de actualización; click-der muestra `checkupdates`
- **dunst**: alterna con `dunstctl set-paused toggle` o desde la module bar

> Listados completos en `SHORTCUTS.md`.

### Validación rápida

```bash
# Kitty y fuente
kitty --version && fc-list | grep -i "MesloLGLDZ"

# i3 + polybar
pkill -x polybar 2>/dev/null; polybar main &  # o reinicia i3 con $mod+Shift+r

# picom (foreground para ver logs)
pkill -x picom 2>/dev/null; picom --config ~/.config/picom/picom.conf

# dunst
notify-send "Prueba" "Dunst OK" && dunstctl is-paused

# NeoVim
nvim --headless "+checkhealth" +qa

# tmux
tmux -V
```

Resultados esperados: Polybar visible, sombras/blur/animaciones (si soportadas) en picom, notificación de `notify-send`, `:checkhealth` sin errores críticos y `Ctrl+s` usable como _prefix_ en tmux.

### Rollback

```bash
# Restaurar backups (si aplicaste mv *.bak)
[ -f ~/.config/kitty/kitty.conf.bak ] && mv -f ~/.config/kitty/kitty.conf{.bak,}
[ -f ~/.config/polybar/config.ini.bak ] && mv -f ~/.config/polybar/config.ini{.bak,}
[ -f ~/.config/picom/picom.conf.bak ] && mv -f ~/.config/picom/picom.conf{.bak,}
[ -f ~/.config/i3/config.bak ] && mv -f ~/.config/i3/config{.bak,}
[ -f ~/.config/dunst/dunstrc.bak ] && mv -f ~/.config/dunst/dunstrc{.bak,}
[ -d ~/.config/nvim.bak ] && rm -rf ~/.config/nvim && mv ~/.config/nvim{.bak,}
[ -f ~/.bashrc.bak ] && mv -f ~/.bashrc{.bak,}

# Elimina symlinks si los usaste
find ~/.config -maxdepth 2 -type l -lname "$HOME/dotfiles/*" -exec rm -f {} \;
```

Si ya hiciste commit, usa `git revert` o `git restore --source <commit>` en este repo.

### Licencia

Indica la licencia que prefieras (MIT/Apache-2.0/GPL-3.0). Añade `LICENSE`.

---

## English

### Overview

Daily-driver dotfiles for **Arch Linux**: i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom and polybar.  
Goals: **performance**, **unified keybindings** (tmux/i3/NeoVim), **consistent theming (Catppuccin Mocha)**, and **fully reversible changes**.

### Requirements (packages)

- i3-wm, polybar, picom, dunst, rofi, kitty, tmux, neovim (≥ 0.11)
- pamixer, pacman-contrib (`checkupdates`), bluez/bluez-utils (if using BT module)
- Fonts: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_

> **Animations note (picom):** if your `picom` lacks animation support, set `animations = false` in `~/.config/picom/picom.conf` or use a build that supports it.

### Install (safe & reversible)

1. **Clone** into `$HOME`:

```bash
cd ~
git clone <YOUR_REPO_URL> dotfiles
```

2. **Backups** and **symlinks** (minimal examples):

```bash
mkdir -p ~/.config/{kitty,polybar,picom,i3,dunst,rofi}
[ -f ~/.config/kitty/kitty.conf ] && mv ~/.config/kitty/kitty.conf{,.bak}
ln -s ~/dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
[ -f ~/.config/polybar/config.ini ] && mv ~/.config/polybar/config.ini{,.bak}
ln -s ~/dotfiles/config/polybar/config.ini ~/.config/polybar/config.ini
[ -f ~/.config/picom/picom.conf ] && mv ~/.config/picom/picom.conf{,.bak}
ln -s ~/dotfiles/config/picom/picom.conf ~/.config/picom/picom.conf
[ -f ~/.config/i3/config ] && mv ~/.config/i3/config{,.bak}
ln -s ~/dotfiles/config/i3/config ~/.config/i3/config
[ -f ~/.config/dunst/dunstrc ] && mv ~/.config/dunst/dunstrc{,.bak}
ln -s ~/dotfiles/config/dunst/dunstrc ~/.config/dunst/dunstrc
[ -f ~/.config/rofi/config.rasi ] && mv ~/.config/rofi/config.rasi{,.bak}
ln -s ~/dotfiles/config/rofi/config.rasi ~/.config/rofi/config.rasi
[ -e ~/.config/nvim ] && mv ~/.config/nvim{,.bak}
ln -s ~/dotfiles/config/nvim ~/.config/nvim
```

3. **NeoVim bootstrap (lazy.nvim)**:

```bash
nvim --headless "+Lazy! sync" +qa
```

4. **Free Ctrl+S for tmux** (disable XON/XOFF):

```bash
grep -q 'stty -ixon' ~/.bashrc || echo 'stty -ixon' >> ~/.bashrc
```

### Keybindings (tmux/i3/NeoVim parity)

- **tmux**: _Prefix_ = **Ctrl+s**
- **NeoVim**:
  - _Leader_ = **Space**; save **\<leader>w**
  - Window navigation **Ctrl+h/j/k/l**
  - Quick splits: **\<leader>"** (horizontal), **\<leader>%** (vertical)
  - Resize: **Alt+Shift + arrows** (and **Ctrl+arrows**)
  - Search: **Ctrl+f** opens `/`
- **kitty**: copy **Ctrl+Shift+C**, paste **Ctrl+Shift+V**, new tab **Ctrl+Shift+Enter**, open URL with **Ctrl+click**
- **polybar** (examples):
  - Mic: left click → _mute/unmute_
  - Updates: left click opens update terminal; right click shows `checkupdates`
- **dunst**: toggle via `dunstctl set-paused toggle` or the bar module

> Full lists live in `SHORTCUTS.md`.

### Validation

```bash
kitty --version
pkill -x polybar 2>/dev/null; polybar main &
pkill -x picom 2>/dev/null; picom --config ~/.config/picom/picom.conf
notify-send "Test" "Dunst OK" && dunstctl is-paused
nvim --headless "+checkhealth" +qa
tmux -V
```

Expected: polybar visible, picom shadows/blur/animations (if supported), `notify-send` pops, `:checkhealth` clean, and `Ctrl+s` usable as tmux prefix.

### Rollback

```bash
find ~/.config -maxdepth 2 -type l -lname "$HOME/dotfiles/*" -exec rm -f {} \;
[ -f ~/.bashrc.bak ] && mv -f ~/.bashrc{.bak,}
[ -d ~/.config/nvim.bak ] && rm -rf ~/.config/nvim && mv ~/.config/nvim{.bak,}
for f in kitty/kitty.conf polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f.bak" ] && mv -f "$HOME/.config/$f"{.bak,}
done
```

If committed, use `git revert` or `git restore`.

### License

Choose your license (MIT/Apache-2.0/GPL-3.0). Add a `LICENSE` file.

---

## Contribuir / Contributing

- Cambios pequeños y atómicos.
- Incluye validación (comandos y resultado esperado) y cómo hacer rollback.
- Mantén compatibilidad con Arch estable.
