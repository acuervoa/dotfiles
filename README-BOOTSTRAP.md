# README-BOOTSTRAP

Guía práctica para desplegar estos **dotfiles** en Arch Linux (o derivadas) mediante `scripts/bootstrap.sh`.
Incluye los paquetes recomendados, el flujo de symlinks/backup, validaciones y un plan B manual con `stow`/`ln -s`.

## 1. Paquetes base (pacman)

```bash
sudo pacman -S --needed git stow bash fzf ripgrep fd bat eza zoxide zsh \
  wl-clipboard xclip trash-cli docker docker-compose bc tmux neovim i3-wm kitty \
  rofi polybar dunst picom lazygit pamixer playerctl brightnessctl bluez bluez-utils \
  python rsync unzip gzip curl wget
```

> Añade tu compositor favorito o paquetes adicionales (p.ej. `pipewire`, `network-manager-applet`) según tu instalación.
> Para animaciones en picom necesitas una build con `--experimental-backends`; si no lo tienes, edita `config/picom/picom.conf`
> y pon `animations = false` tras el bootstrap.

### Extras sugeridos
- **Fuentes:** `ttf-meslo-nerd`, `noto-fonts-emoji`.
- **Gestión de versiones:** `mise` (ver `config/mise/config.toml`).
- **Bluetooth:** `bluez` + `bluez-utils` para los módulos Polybar (incluidos arriba).

## 2. Clonar el repo

```bash
cd ~
git clone https://github.com/<tu-usuario>/dotfiles.git
cd dotfiles
```

## 3. Bootstrap automatizado

El script enlaza Bash, Git, tmux, NeoVim/Vim, Kitty, i3, polybar, rofi, picom, dunst, lazygit, atuin, blesh, mise, yazi, etc.,
creando copias de seguridad previas en `~/.dotfiles_backup_<TS>`.

```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh
```

El script:
1. Detecta el directorio del repo a partir de la ubicación del script.
2. Para cada archivo/dir enlazado, mueve el destino existente al backup antes de crear el symlink.
3. Crea enlaces simbólicos hacia:
   - `bash/*` → `~/.bashrc`, `~/.bash_profile`, `~/.bash_lib`, etc.
   - `config/*` → `~/.config/{atuin,blesh,dunst,i3,kitty,lazygit,mise,nvim,picom,polybar,rofi,yazi}`.
   - `git/gitconfig`, `git/gitalias`, `git/git-hooks`.
   - `tmux/tmux.conf`, `tmux/`.
   - `vim/vimrc`, `vim/`, `vim/vim-tmp`.
4. Informa de la ruta del backup generado o avisa si no hizo falta copiar nada.

> Los backups son carpetas completas que puedes restaurar con `scripts/rollback.sh` (ver sección 5).

## 4. Validaciones rápidas

```bash
# Bash + librería modular
source ~/.bashrc
for lib in ~/.bash_lib/*.sh; do bash -n "$lib" && . "$lib"; done

# Symlinks críticos
for p in \
  ~/.config/{kitty/kitty.conf,lazygit/config.yml,polybar/config.ini,picom/picom.conf,i3/config,dunst/dunstrc,rofi/config.rasi,nvim} \
  ~/.bashrc ~/.gitconfig ~/.tmux.conf ~/.vimrc; do
  [ -L "$p" ] && echo "OK -> $(readlink -f "$p")" || echo "MISSING $p"
done
```

## 5. Rollback

Todos los backups siguen el patrón `~/.dotfiles_backup_YYYYmmdd_HHMMSS`. Para restaurar el último:

```bash
bash ./scripts/rollback.sh
```

O bien pasa la ruta concreta del backup que quieras reaplicar:

```bash
bash ./scripts/rollback.sh ~/.dotfiles_backup_20250101_120000
```

`rollback.sh` usa `rsync` con `--backup-dir` para guardar en `~/.dotfiles_rollback_conflicts_<TS>` cualquier archivo actual que
vaya a sobrescribir.

## 6. Plan B (sin script)

Si prefieres hacerlo a mano:

```bash
cd ~/dotfiles
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
ln -sfn "$PWD/vim/vim-tmp" "$HOME/.vim-tmp"

for pkg in atuin blesh dunst i3 kitty lazygit mise nvim picom polybar rofi yazi; do
  mkdir -p "$HOME/.config/$pkg"
  stow -vt "$HOME/.config" "config/$pkg" -S
done
```

## 7. Después del bootstrap

- `mise install` para instalar los runtimes declarados en `config/mise/config.toml`.
- `direnv allow` en los proyectos que lo usen (el hook ya está en `~/.bashrc`).
- `tmux` + `prefix + I` para instalar los plugins de TPM.
- `nvim` → `:Lazy sync` / `:Mason` para descargar plugins y toolchains.
- Ejecuta `polybar/launch.sh`, `picom --config ~/.config/picom/picom.conf` o reinicia i3 para aplicar la parte gráfica.
