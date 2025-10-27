# README-BOOTSTRAP

Guía rápida para levantar el entorno de **dotfiles** en Arch con **backups**, **symlinks** y **librería Bash modular**.

## Paquetes base (Arch)
```bash
sudo pacman -S --needed git stow bash fzf ripgrep fd bat eza zoxide       wl-clipboard xclip trash-cli docker docker-compose bc       tmux neovim i3-wm kitty rofi polybar dunst picom
```

## Estructura
- Home: `bash/` (bashrc, aliases, profile, xprofile…)
- Config: `config/{kitty,polybar,picom,i3,dunst,rofi,nvim}`
- Docs: `README.md`, `README-BOOTSTRAP.md`, `SHORTCUTS.md`, `CHANGELOG.md`

## Bootstrap (vía scripts)
```bash
cd ~/dotfiles
bash ./scripts/bootstrap.sh --dry-run
bash ./scripts/bootstrap.sh
```

## Bootstrap manual con stow (mínimo)
```bash
cd ~/dotfiles
for f in bash/bashrc bash/bash_aliases bash/bash_profile bash/profile bash/xprofile; do
  base=$(basename "$f"); [ -f "$HOME/.${base}" ] && cp -a "$HOME/.${base}" "$HOME/.${base}.bak"
  stow -vt "$HOME" "$(dirname "$f")" -S
done

for pkg in kitty polybar picom i3 dunst rofi nvim; do
  mkdir -p "$HOME/.config/$pkg"
  [ -e "$HOME/.config/$pkg" ] && true
  stow -vt "$HOME/.config" "config/$pkg" -S
done
```

## Librería Bash modular
```bash
# En ~/.bashrc (carga condicional de módulos)
[ -f "$HOME/.bash_lib/core.sh"   ] && . "$HOME/.bash_lib/core.sh"
[ -f "$HOME/.bash_lib/git.sh"    ] && . "$HOME/.bash_lib/git.sh"
[ -f "$HOME/.bash_lib/nav.sh"    ] && . "$HOME/.bash_lib/nav.sh"
[ -f "$HOME/.bash_lib/docker.sh" ] && . "$HOME/.bash_lib/docker.sh"
[ -f "$HOME/.bash_lib/misc.sh"   ] && . "$HOME/.bash_lib/misc.sh"
```

## Validación rápida
```bash
source ~/.bashrc
bash -n ~/.bash_lib/*.sh && for f in ~/.bash_lib/*.sh; do . "$f"; done
type gbr gcof gclean docps dlogs dsh fo cdf rgf cb bench >/dev/null
```

## Rollback
```bash
bash ./scripts/rollback.sh latest
```
