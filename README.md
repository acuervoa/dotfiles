## Español

### Resumen

Dotfiles listos para uso diario en **Arch Linux**: i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom y polybar.  
Objetivos: **rendimiento**, **atajos coherentes** (paridad tmux/i3/NeoVim), **estética consistente (Catppuccin Mocha)** y **cambios reversibles**.

### Requisitos (paquetes Arch)

- i3-wm, polybar, picom, dunst, rofi, kitty, tmux, neovim (≥ 0.11)
- pamixer, pacman-contrib (`checkupdates`), bluez/bluez-utils (si usas el módulo BT)
- Fuentes: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_

> **Animaciones (picom):** si tu build no soporta animaciones, pon `animations = false` en `~/.config/picom/picom.conf` o usa un build con soporte.  
> **Ctrl+S (tmux):** añade `stty -ixon` a tu `~/.bashrc` para liberar `Ctrl+s` (desactiva XON/XOFF).

### Estructura

```
dotfiles/
├── bash/                 # bashrc, aliases, profile, xprofile...
├── config/
│   ├── dunst/            # dunstrc, scripts (micctl, volctl)
│   ├── i3/               # config + scripts (i3lock, i3exit, toggle_scratch...)
│   ├── kitty/            # kitty.conf (Catppuccin Mocha)
│   ├── nvim/             # init.lua, lua/config/* (lazy.nvim)
│   ├── picom/            # picom.conf (GLX, blur, animaciones) + picom-lowlatency.conf
│   ├── polybar/          # config.ini + scripts (updates, dunst, mic, bt...)
│   └── rofi/             # config.rasi + temas
├── README.md
├── README-BOOTSTRAP.md
└── SHORTCUTS.md
```

### Instalación segura (backups + symlinks)

1. **Clona** en `$HOME`:

```bash
cd ~
git clone <URL_DE_TU_REPO> dotfiles
```

2. **Backups** y **symlinks** mínimos:

```bash
mkdir -p ~/.config/{kitty,polybar,picom,i3,dunst,rofi}
[ -f ~/.config/kitty/kitty.conf ]   && mv ~/.config/kitty/kitty.conf{,.bak}
ln -sf ~/dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
[ -f ~/.config/polybar/config.ini ] && mv ~/.config/polybar/config.ini{,.bak}
ln -sf ~/dotfiles/config/polybar/config.ini ~/.config/polybar/config.ini
[ -f ~/.config/picom/picom.conf ]   && mv ~/.config/picom/picom.conf{,.bak}
ln -sf ~/dotfiles/config/picom/picom.conf ~/.config/picom/picom.conf
[ -f ~/.config/i3/config ]          && mv ~/.config/i3/config{,.bak}
ln -sf ~/dotfiles/config/i3/config ~/.config/i3/config
[ -f ~/.config/dunst/dunstrc ]      && mv ~/.config/dunst/dunstrc{,.bak}
ln -sf ~/dotfiles/config/dunst/dunstrc ~/.config/dunst/dunstrc
[ -f ~/.config/rofi/config.rasi ]   && mv ~/.config/rofi/config.rasi{,.bak}
ln -sf ~/dotfiles/config/rofi/config.rasi ~/.config/rofi/config.rasi
[ -e ~/.config/nvim ]               && mv ~/.config/nvim{,.bak}
ln -s  ~/dotfiles/config/nvim ~/.config/nvim
```

3. **Bootstrap NeoVim (lazy.nvim)**:

```bash
nvim --headless "+Lazy! sync" +qa
```

4. **Libera Ctrl+S para tmux**:

```bash
grep -q 'stty -ixon' ~/.bashrc || echo 'stty -ixon' >> ~/.bashrc
```

### Monitores (polybar)

Config soporta `${env:MONITOR:eDP-1}` y `${env:MONITOR2:DP-1}`.  
Ejemplo:

```bash
MONITOR=eDP-1 MONITOR2=DP-1 polybar -r main &
```

### Perfiles picom

- **Completo (con animaciones/blur)**:

```bash
picom --config ~/.config/picom/picom.conf -b
```

- **Low-latency (sin animaciones/blur)**:

```bash
picom --config ~/.config/picom/picom-lowlatency.conf -b
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

Esperado: Polybar visible; picom con sombras/blur/animaciones (según perfil); `notify-send` muestra una notificación; `:checkhealth` sin errores críticos; `Ctrl+s` usable como prefix tmux.

### Rollback

```bash
find ~/.config -maxdepth 2 -type l -lname "$HOME/dotfiles/*" -exec rm -f {} \;
[ -f ~/.bashrc.bak ] && mv -f ~/.bashrc{.bak,}
[ -d ~/.config/nvim.bak ] && rm -rf ~/.config/nvim && mv ~/.config/nvim{.bak,}
for f in kitty/kitty.conf polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f.bak" ] && mv -f "$HOME/.config/$f"{.bak,}
done
```

### Licencia

MIT

---

## English

### Overview

Daily-driver dotfiles for **Arch Linux**: i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom and polybar.  
Goals: **performance**, **unified keybindings** (tmux/i3/NeoVim), **consistent theming (Catppuccin Mocha)**, **reversible changes**.

### Requirements

- i3-wm, polybar, picom, dunst, rofi, kitty, tmux, neovim (≥ 0.11)
- pamixer, pacman-contrib (`checkupdates`), bluez/bluez-utils (if using BT module)
- Fonts: _MesloLGLDZ Nerd Font_, _Noto Color Emoji_

### Install (safe & reversible)

```bash
cd ~ && git clone <YOUR_REPO_URL> dotfiles
```

Symlinks (minimal set):

```bash
mkdir -p ~/.config/{kitty,polybar,picom,i3,dunst,rofi}
for f in kitty/kitty.conf polybar/config.ini picom/picom.conf i3/config dunst/dunstrc rofi/config.rasi; do
  [ -f "$HOME/.config/$f" ] && mv "$HOME/.config/$f"{,.bak}
  ln -sf "$HOME/dotfiles/config/$f" "$HOME/.config/$f"
done
[ -e ~/.config/nvim ] && mv ~/.config/nvim{,.bak}
ln -s ~/dotfiles/config/nvim ~/.config/nvim
```

NeoVim bootstrap:

```bash
nvim --headless "+Lazy! sync" +qa
```

Free `Ctrl+S` for tmux:

```bash
grep -q 'stty -ixon' ~/.bashrc || echo 'stty -ixon' >> ~/.bashrc
```

### Polybar monitors

Use `${env:MONITOR:eDP-1}` and `${env:MONITOR2:DP-1}`. Example:

```bash
MONITOR=eDP-1 MONITOR2=DP-1 polybar -r main &
```

### Picom profiles

```bash
picom --config ~/.config/picom/picom.conf -b
picom --config ~/.config/picom/picom-lowlatency.conf -b
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

### License

MIT
