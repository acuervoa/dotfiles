# Dotfiles · Arch Linux · Entorno de trabajo

Daily-driver dotfiles para **Arch Linux**: i3, tmux, NeoVim/Vim, kitty, rofi, dunst, picom y polybar.
Objetivos: **rendimiento**, **atajos coherentes** (paridad tmux/i3/NeoVim), **estética consistente (Catppuccin Mocha)** y **cambios reversibles**.

---

# Bootstrap, Backups & Rollback

## Requisitos

- GNU stow (`sudo pacman -S stow`)

## Bootstrap (dry-run)

```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh --dry-run
```

## Bootstrap (aplicar)

```bash
bash ./scripts/bootstrap.sh
```

Crea `./.backups/<TS>/` y `./.manifests/<TS>.manifest` y enlaza:

- Bash/Git/Tmux/Vim ⇒ $HOME
- Paquetes `config/*` ⇒ `~/.config` (stow)

## Plan B (si no usas scripts)

> Requiere stow (instala con sudo pacman -S stow).

```bash
cd ~/dotfiles
# Home-level (bash y similares)
for f in bash/bashrc bash/bash_aliases bash/bash_profile bash/profile bash/xprofile; do
  base=$(basename "$f"); [ -f "$HOME/.${base}" ] && cp -a "$HOME/.${base}" "$HOME/.${base}.bak"
  stow -vt "$HOME" "$(dirname "$f")" -S
done
# Configs bajo ~/.config (ejemplos)
stow -vt "$HOME/.config" config/kitty -S
stow -vt "$HOME/.config" config/polybar -S
stow -vt "$HOME/.config" config/picom -S
stow -vt "$HOME/.config" config/i3 -S
stow -vt "$HOME/.config" config/dunst -S
stow -vt "$HOME/.config" config/rofi -S
stow -vt "$HOME/.config" config/nvim -S
```

## Validación (bootstrap)

```bash
# Symlinks creados
for p in ~/.config/{kitty/kitty.conf,polybar/config.ini,picom/picom.conf,i3/config,dunst/dunstrc,rofi/config.rasi,nvim}; do
  [ -L "$p" ] && echo "OK $p -> $(readlink -f "$p")" || echo "MISSING $p"
done
```

## Rollback (último)

```bash
bash ./scripts/rollback.sh latest
```

O por timestamp:

```bash
bash ./scripts/rollback.sh 20251020-120000
```

## Modo alternativo: git bare

Documentado en `bootstrap.sh --mode=bare` (no se ejecuta por defecto).

---

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

## Shell helpers (bash)

**Ubicación:** `~/.bash_lib/{core,git,nav,docker,misc}.sh`  
**Requisitos (Arch):**

```bash
sudo pacman -S --needed fzf fd ripgrep bat eza zoxide wl-clipboard xclip trash-cli docker docker-compose bc
```

> `cb` usa `wl-copy` (Wayland) o `xclip` (X11); `bench` usa `bc` o `awk`.

**Destacados:**

- Buscar/abrir: `fo` (ficheros/dirs con preview), `rgf "patrón"` (ripgrep + salto a línea).
- Saltos: `cdf` (zoxide), `grt` (raíz del repo).
- Git: `gcof`, `gbr`, `gstaged`, `gundo`, `gclean`, `checkpoint`, `wip`, `fixup`, `watchdiff`.
- Docker: `docps`, `dlogs`, `dsh`.
- Utilidades: `fkill`, `cb`, `fhist`, `take`, `extract`, `t`, `ports`, `topme`, `r`, `tt`, `trash`, `bench`, `redo`, `envswap`, `todo`.

---

## Hooks de Git (reproducibles)

Instala hooks centralizados en `~/.git-hooks/` (el bootstrap los enlaza ahí) y apúntalos globalmente:

```bash
mkdir -p ~/.git-hooks
# Copiar los hooks del repo (ajusta la ruta de origen según tu estructura):
cp -f ./git/git-hooks/pre-commit ~/.git-hooks/pre-commit
cp -f ./git/git-hooks/commit-msg ~/.git-hooks/commit-msg
chmod +x ~/.git-hooks/{pre-commit,commit-msg}

# Usar ruta global para todos los repos
git config --global core.hooksPath "$HOME/.git-hooks"
```

**Qué hacen:**

- **pre-commit**: bloquea trazas (`console.log`, `var_dump`, etc.) y ficheros sensibles (`.env*`, `docker-compose.override.yml`) si están _staged_.
- **commit-msg**: rechaza mensajes con `WIP`/`tmp`.

**Consejos:**

- Para cambios rápidos sin ensuciar el historial, usa `wip`, `fixup`, y luego `git rebase -i --autosquash`.

---

## Verificación rápida

```bash
# Sintaxis y carga de funciones
bash -n ~/.bash_lib/*.sh && for f in ~/.bash_lib/*.sh; do . "$f"; done

# Smoke tests
type fo cdf rgf fkill cb gbr dlogs dsh bench >/dev/null

# Hooks activos
git config --global core.hooksPath
test -x ~/.git-hooks/pre-commit
test -x ~/.git-hooks/commit-msg
```

**Pruebas de hooks:**

```bash
# pre-commit: crear fichero con 'console.log' y probar
echo 'console.log("debug")' > test.js
git add test.js && git commit -m "prueba" || echo "OK: hook bloqueó el commit"
git reset HEAD test.js && rm test.js

# commit-msg: WIP
git commit --allow-empty -m "WIP prueba" || echo "OK: commit-msg bloqueó el mensaje"
```

### License

MIT
