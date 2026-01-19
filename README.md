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
6. [Gestión de Secretos y Personalización](#gestión-de-secretos-y-personalización)
7. [Documentación dinámica](#documentación-dinámica)
8. [Uso manual de Stow (Alternativa)](#uso-manual-de-stow-alternativa)
9. [Componentes principales](#componentes-principales)
10. [Validaciones rápidas](#validaciones-rápidas)
11. [Licencia](#licencia)

---

## Pila y highlights

- **Gestión con GNU Stow**: El versionado se basa en `stow` para gestionar los symlinks de forma declarativa.
- **Bootstrap reproducible**: `scripts/bootstrap.sh` automatiza la instalación con `stow` y crea backups timestamp en `.backups/<TS>`.
- **Rollback automático**: `scripts/rollback.sh <timestamp|latest>` elimina los symlinks con `stow` y restaura el backup elegido.
- **Gestión de secretos**: Soporte para ficheros locales (ej. `~/.bashrc_local`) no versionados para información sensible.
- **Documentación dinámica**: Script para generar `SHORTCUTS.md` a partir de los ficheros de configuración.
- **Librería Bash modular** (`stow/bash/.bash_lib/*.sh`) con helpers para git, docker, navegación y productividad.
- **NeoVim** (≥0.11) con lazy.nvim, Mason v2, Treesitter, LSP/DAP, etc.
- **tmux** con prefix `Ctrl+s` e integración con NeoVim y TPM.
- **Stack gráfico** tematizado (Catppuccin Mocha): i3, polybar, picom, dunst, rofi, kitty.

---

## Estructura del repositorio

El repositorio usa una estructura compatible con `stow`. Todas las configuraciones residen en el directorio `stow/`, agrupadas por "paquetes".

```
dotfiles/
├── stow/
│   ├── bash/         # Configs de Bash (van a $HOME)
│   ├── git/          # Configs de Git (van a $HOME)
│   ├── nvim/         # Configs de NeoVim (van a $HOME/.config)
│   └── ...           # y así para cada paquete
├── scripts/
│   ├── bootstrap.sh  # Script de instalación (usa stow)
│   ├── rollback.sh   # Script de rollback (usa stow)
│   └── install_deps.sh # Script de instalación de dependencias
├── .backups/         # Backups de configuraciones existentes
└── pkglist-arch.txt  # Lista de paquetes para Arch Linux
```

---

## Requisitos

1.  **GNU Stow**: `sudo pacman -S stow`.
2.  **Paquetes base**: El script `scripts/install_deps.sh` se encarga de instalar las dependencias.

Para instalar los paquetes, ejecuta:
```bash
bash ./scripts/install_deps.sh
```
El script detectará tu sistema operativo y te pedirá confirmación para instalar los paquetes listados en `pkglist-arch.txt`.

---

## Bootstrap

El script `bootstrap.sh` es un wrapper sobre `stow` que además gestiona backups.

1.  **Simulación**: `bash ./scripts/bootstrap.sh --dry-run`
2.  **Aplicar**: `bash ./scripts/bootstrap.sh`

**Acciones principales:**
- **Detecta conflictos** y mueve los ficheros existentes a `.backups/<TIMESTAMP>/`.
- **Crea symlinks** con `stow` para cada paquete en el directorio `stow/`.

---

## Rollback

El script `rollback.sh` revierte los cambios hechos por el bootstrap.

- **Último backup**: `bash ./scripts/rollback.sh latest`
- **Backup específico**: `bash ./scripts/rollback.sh <timestamp>`

**Acciones principales:**
- **Elimina symlinks** con `stow -D`.
- **Restaura backups** desde `.backups/` con `rsync`.

---

## Gestión de Secretos y Personalización

Para evitar versionar información sensible (API keys, tokens, datos personales), este repositorio utiliza un sistema de ficheros locales no versionados. Simplemente crea un fichero con el sufijo `_local` (ej. `.bashrc_local`, `.gitconfig_local`) y será ignorado por Git.

La configuración principal ya está preparada para cargar estos ficheros si existen.

### Ejemplo de Bash
Puedes crear un `~/.bashrc_local` para definir variables de entorno o alias privados:
```bash
# ~/.bashrc_local
export GITHUB_TOKEN="ghp_..."
alias work="cd ~/proyectos/trabajo"
```

### Ejemplo de Git
Para tu configuración personal de Git (nombre y email), puedes crear un `~/.gitconfig_local`:
```ini
# ~/.gitconfig_local
[user]
    name = Tu Nombre
    email = tu@email.com
```

---

## Uso manual de Stow (Alternativa)

Si prefieres no usar los scripts, puedes usar `stow` directamente desde la raíz del repositorio.

- **Instalar un paquete**: `stow -d stow -t "$HOME" -S bash`
- **Desinstalar un paquete**: `stow -d stow -t "$HOME" -D bash`

---

## Documentación dinámica

Para asegurar que el fichero `SHORTCUTS.md` esté siempre actualizado, se ha creado un script que extrae automáticamente los atajos de teclado de los ficheros de configuración.

Para generar o actualizar `SHORTCUTS.md`, ejecuta:
```bash
bash ./scripts/generate_shortcuts_doc.sh
```

---

## Componentes principales

- **Bash library**: `stow/bash/.bash_lib/{core,git,nav,docker,misc}.sh`.
- **Git tooling**: `stow/git/.gitconfig`, `stow/git/.gitalias`, `stow/git/.git-hooks/*`.
- **NeoVim**: `stow/nvim/.config/nvim/`.
- ... y el resto de configuraciones siguen una estructura similar dentro de `stow/`.

---

## Validaciones rápidas

```bash
# Verificar symlinks
for p in ~/.config/{kitty,lazygit,polybar,picom,i3,dunst,rofi,nvim}; do
  [ -L "$p" ] && echo "OK $p" || echo "MISSING $p"
done
# Lanzar servicios clave
kitty --version; tmux -V; nvim --headless "+checkhealth" +qa
```

---

## Licencia

[MIT](LICENSE)