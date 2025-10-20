#!/usr/bin/env bash
# Bootstrap dotfiles — backups + symlinks + stow + manifest
# Uso:
#   ./scripts/bootstrap.sh [--dry-run] [--mode=stow|bare]
# Variables:
#   DOTFILES (por defecto: $HOME/dotfiles)
set -Eeuo pipefail

MODE="stow"
DRYRUN=false
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$DOTFILES/.backups"
MANIFEST_ROOT="$DOTFILES/.manifests"
BACKUP_DIR="$BACKUP_ROOT/$TS"
MANIFEST="$MANIFEST_ROOT/$TS.manifest"
# Paquetes por defecto bajo ~/.config
PACKAGES_DEF=(dunst i3 kitty nvim picom polybar rofi)

usage() {
  cat <<EOF
Uso: $(basename "$0") [opciones]
  --dry-run, -n       Simula acciones (no escribe nada)
  --mode=stow|bare    'stow' (por defecto) o 'bare' (alternativa)
  --help, -h          Ayuda
Notas:
  - En modo 'stow' crea backups con timestamp y symlinks.
  - Enlaza bash/git/tmux/vim explícitamente a \$HOME.
  - Stowea paquetes de ~/.config: ${PACKAGES_DEF[*]}
EOF
}

note(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }
act(){ if $DRYRUN; then echo "DRYRUN: $*"; else eval "$@"; fi; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRYRUN=true ;;
    --mode=*) MODE="${1#*=}" ;;
    --help|-h) usage; exit 0 ;;
    *) die "Opción desconocida: $1" ;;
  esac
  shift
done

mkdir -p "$BACKUP_DIR" "$MANIFEST_ROOT"

# Guarda archivo existente en BACKUP_DIR conservando estructura
backup_path() {
  local p="$1"
  if [[ -e "$p" || -L "$p" ]]; then
    local dest="$BACKUP_DIR${p}"
    act "mkdir -p '$(dirname "$dest")'"
    # copia preservando atributos; si es symlink copia el enlace
    act "cp -a --no-preserve=ownership '$p' '$dest' 2>/dev/null || true"
  fi
}

# Crea symlink seguro con backup previo y registra en MANIFEST
link_to() {
  local src="$1" dest="$2"
  [[ -e "$src" || -L "$src" ]] || return 0
  backup_path "$dest"
  act "mkdir -p '$(dirname "$dest")'"
  act "ln -sfn '$src' '$dest'"
  echo "LINK $src -> $dest" >>"$MANIFEST"
}

if [[ "$MODE" == "stow" ]]; then
  command -v stow >/dev/null 2>&1 || die "stow no está instalado. Instala con: sudo pacman -S stow"
  note "Modo: stow | Backups: $BACKUP_DIR"

  # 1) Enlaces explícitos en $HOME (bash, git, tmux, vim)
  # bash
  link_to "$DOTFILES/bash/bashrc"        "$HOME/.bashrc"
  link_to "$DOTFILES/bash/bash_profile"  "$HOME/.bash_profile"
  link_to "$DOTFILES/bash/profile"       "$HOME/.profile"
  link_to "$DOTFILES/bash/xprofile"      "$HOME/.xprofile"
  link_to "$DOTFILES/bash/bash_aliases"  "$HOME/.bash_aliases"
  link_to "$DOTFILES/bash/bash_functions"$HOME/.bash_functions"
  # git
  link_to "$DOTFILES/git/gitconfig"      "$HOME/.gitconfig"
  link_to "$DOTFILES/git/gitalias"       "$HOME/.gitalias"
  # tmux
  link_to "$DOTFILES/tmux/tmux.conf"     "$HOME/.tmux.conf"
  if [[ -d "$DOTFILES/tmux/tmux" ]]; then
    backup_path "$HOME/.tmux"
    act "ln -sfn '$DOTFILES/tmux/tmux' '$HOME/.tmux'"
    echo "LINK $DOTFILES/tmux/tmux -> $HOME/.tmux" >>"$MANIFEST"
  fi
  # vim
  link_to "$DOTFILES/vim/vimrc"          "$HOME/.vimrc"
  if [[ -d "$DOTFILES/vim/vim" ]]; then
    backup_path "$HOME/.vim"
    act "ln -sfn '$DOTFILES/vim/vim' '$HOME/.vim'"
    echo "LINK $DOTFILES/vim/vim -> $HOME/.vim" >>"$MANIFEST"
  fi

  # 2) Stow para ~/.config
  pushd "$DOTFILES/config" >/dev/null
  echo "PACKAGES ${PACKAGES_DEF[*]}" >>"$MANIFEST"
  STOW_FLAGS="-v"
  $DRYRUN && STOW_FLAGS="-n -v"
  act "stow $STOW_FLAGS -t '$HOME/.config' ${PACKAGES_DEF[*]}"
  popd >/dev/null

  note "Hecho. Manifest: $MANIFEST"
  note "Backup dir: $BACKUP_DIR"

elif [[ "$MODE" == "bare" ]]; then
  note "Modo: bare (alternativo). No se aplican symlinks ni stow."
  cat <<'EOF'
Pasos sugeridos (manuales) para git bare:

  # 1) Inicializa bare
  git init --bare "$HOME/.dotfiles.git"
  git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" config status.showUntrackedFiles no

  # 2) Alias conveniente en tu shell
  echo "alias dot='git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME'" >> "$HOME/.bash_aliases"
  # (reinicia shell) y prueba con:  dot status

  # 3) Añade y commitea los archivos deseados
  #    OJO: este enfoque gestiona ficheros en $HOME directamente (sin stow).
EOF
  echo "MODE bare" > "$MANIFEST"
else
  die "Modo no soportado: $MODE"
fi

exit 0
