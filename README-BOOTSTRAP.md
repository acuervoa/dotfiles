# README-BOOTSTRAP (ES)

Guía práctica para desplegar estos **dotfiles** en una instalación limpia.

- Linux desktop (Arch/Debian/Fedora)
- WSL2 (modo CLI; sin i3/polybar/picom)

> Importante: `scripts/bootstrap.sh` y `scripts/rollback.sh` modifican `$HOME`.
> Haz `--dry-run` antes y entiende qué va a mover a `.backups/`.

## 1) Clonar el repo

```bash
cd ~
git clone https://github.com/<tu-usuario>/dotfiles.git
cd dotfiles
```

### Submódulos (plugins tmux/vim)

Este repo incluye plugins de tmux/vim como **submódulos**. Tras clonar:

```bash
git submodule update --init --recursive
```

(Alternativa: `bash ./scripts/bootstrap.sh --init-submodules`.)

## 2) Instalar dependencias (multi-distro)

El script `scripts/install_deps.sh` detecta Arch/Debian/Fedora y usa un pkglist
por distro:

- `pkglist-arch.txt`
- `pkglist-debian.txt`
- `pkglist-fedora.txt`
- `pkglist-wsl.txt`

### Core (CLI) — recomendado para empezar

```bash
bash ./scripts/install_deps.sh --core
```

### Core + GUI (solo desktop Linux, no WSL)

```bash
bash ./scripts/install_deps.sh --all
# o
bash ./scripts/install_deps.sh --core --gui
```

Tips:
- En WSL2 el script fuerza `--core`.
- Si algún paquete no existe en tu distro/release, el script lo reporta como
  “fallido” para que lo instales o ajustes el pkglist.

## 3) Bootstrap (Stow + backup + manifest)

Siempre empieza con simulación:

```bash
bash ./scripts/bootstrap.sh --dry-run
```

Aplicar (interactivo):

```bash
bash ./scripts/bootstrap.sh
```

El bootstrap:
- Detecta conflictos (targets existentes que no son symlinks)
- Mueve esos archivos a `.backups/<TS>/`
- Crea symlinks con `stow`
- Genera `.manifests/<TS>.manifest`

Opciones útiles:
- `--core-only` para omitir GUI (WSL/servers)
- `--gui` para forzar GUI (desktop)
- `--yes` para no preguntar confirmación
- `--init-submodules` para inicializar submódulos

## 4) Después del bootstrap

- **tmux**: abre `tmux` y luego `prefix + I` para instalar plugins vía TPM.
- **Neovim**: abre `nvim` y ejecuta `:Lazy sync` / `:Mason`.
- **mise** (si lo usas): `mise install`.

## 5) Validaciones rápidas

```bash
# Symlinks críticos
for p in \
  ~/.config/{kitty,lazygit,polybar,picom,i3,dunst,rofi,nvim} \
  ~/.bashrc ~/.gitconfig ~/.tmux.conf ~/.vimrc; do
  [ -L "$p" ] && echo "OK -> $(readlink -f "$p")" || echo "MISSING $p"
done

# Neovim carga headless
nvim --headless "+checkhealth" +qa
```

## 6) Rollback

Restaurar el último backup/manifest:

```bash
bash ./scripts/rollback.sh latest
```

Restaurar por timestamp:

```bash
bash ./scripts/rollback.sh <timestamp>
```

Usar un manifest específico:

```bash
bash ./scripts/rollback.sh --manifest .manifests/<timestamp>.manifest
```

Opciones útiles:
- `--dry-run` para ver acciones sin tocar nada
- `--core-only` para omitir GUI (sin manifest)
- `--gui` para forzar GUI (sin manifest)
- `--yes` para no preguntar confirmación

Rollback:
- Desinstala paquetes con `stow -D`
- Restaura `.backups/<TS>/` con `rsync` (guardando conflictos en
  `~/.dotfiles_rollback_conflicts_<TS>`)

## 7) Plan B (manual con stow)

Si prefieres no usar scripts:

```bash
# $HOME
stow -d stow -t "$HOME" -S bash git tmux vim

# $HOME/.config
mkdir -p "$HOME/.config"
stow -d stow -t "$HOME/.config" -S atuin blesh dunst i3 kitty lazygit mise nvim picom polybar rofi yazi
```

> Nota: el plan B no crea backups/manifest automáticamente.
