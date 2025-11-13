#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/bash" ]; then
	REPO_DIR="$SCRIPT_DIR"
else
	REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

BACKUP_DIR=""

ensure_backup_dir() {
	if [ -z "$BACKUP_DIR" ]; then
		BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
		mkdir -p "$BACKUP_DIR"
		echo "[INFO] Creando directorio de backup en $BACKUP_DIR"
	fi
}

link_item() {
	local rel_path="$1"
	local target_rel="$2" # relativo a $HOME
	local src="$REPO_DIR/$rel_path"
	local dest="$HOME/$target_rel"

	if [ ! -e "$src" ] && [ ! -d "$src" ]; then
		echo "[WARN] Origen no existe: $src (saltando)"
		return 0
	fi

	# Si ya es el symlink correcto, no hacemos nada
	if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
		echo "[OK]  $dest ya apunta a $src"
		return 0
	fi

	# Backup si existe algo en destino
	if [ -e "$dest" ] || [ -L "$dest" ]; then
		ensure_backup_dir
		local backup_dest="$BACKUP_DIR/$target_rel"
		mkdir -p "$(dirname "$backup_dest")"
		echo "[INFO] Moviendo $dest a $backup_dest"
		mv "$dest" "$backup_dest"
	fi

	mkdir -p "$(dirname "$dest")"
	echo "[LINK] $dest -> $src"
	ln -s "$src" "$dest"
}

main() {
	echo "[INFO] Repo de dotfiles: $REPO_DIR"
	echo "[INFO] Instalando symlinks en $HOME"
	echo

	# --- Bash ---
	link_item "bash/bashrc" ".bashrc"
	link_item "bash/bash_profile" ".bash_profile"
	link_item "bash/profile" ".profile"
	link_item "bash/xprofile" ".xprofile"
	link_item "bash/bash_aliases" ".bash_aliases"
	link_item "bash/bash_functions" ".bash_functions"
	link_item "bash/bash_lib" ".bash_lib"

	# --- Config (~/.config/...) ---
	link_item "config/atuin" ".config/atuin"
	link_item "config/blesh" ".config/blesh"
	link_item "config/dunst" ".config/dunst"
	link_item "config/i3" ".config/i3"
	link_item "config/kitty" ".config/kitty"
	link_item "config/lazygit" ".config/lazygit"
	link_item "config/mise" ".config/mise"
	link_item "config/nvim" ".config/nvim"
	link_item "config/picom" ".config/picom"
	link_item "config/polybar" ".config/polybar"
	link_item "config/rofi" ".config/rofi"
	link_item "config/yazi" ".config/yazi"

	# --- Git ---
	link_item "git/gitconfig" ".gitconfig"
	link_item "git/gitalias" ".gitalias"
	link_item "git/git-hooks" ".git-hooks"

	# --- Tmux ---
	link_item "tmux/tmux.conf" ".tmux.conf"
	link_item "tmux/tmux" ".tmux"

	# --- Vim ---
	link_item "vim/vimrc" ".vimrc"
	link_item "vim/vim" ".vim"
	link_item "vim/vim-tmp" ".vim-tmp"

	echo
	echo "[INFO] Instalación de dotfiles completada."
	if [ -n "$BACKUP_DIR" ]; then
		echo "[INFO] Copias de seguridad en: $BACKUP_DIR"
	else
		echo "[INFO] No ha sido necesario crear copias de seguridad (no había nada que pisar)."
	fi
}

main "$@"
