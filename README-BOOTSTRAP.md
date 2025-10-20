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
