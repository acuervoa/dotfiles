#!/usr/bin/env bash
set -euo pipefail

info() {
    printf '[INFO] %s\n' "$*"
}

error() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

main() {
    info "Iniciando la instalación de dependencias..."

    if [ -f /etc/arch-release ]; then
        info "Sistema Arch Linux detectado."
        if [ ! -f "pkglist-arch.txt" ]; then
            error "No se encontró el fichero 'pkglist-arch.txt'."
        fi
        info "Instalando paquetes desde pkglist-arch.txt..."
        
        # Leer paquetes, ignorar comentarios y líneas vacías
        packages=$(grep -vE "^\s*#|^\s*$" pkglist-arch.txt | tr '\n' ' ')
        
        # Preguntar al usuario antes de instalar
        read -r -p "¿Instalar los siguientes paquetes? (sudo pacman -S --needed) [y/N]
$packages
" ans
        case "$ans" in
        [yY][eE][sS] | [yY])
            sudo pacman -S --needed $packages
            ;;
        *)
            info "Instalación cancelada por el usuario."
            exit 0
            ;;
        esac
    elif [ -f /etc/debian_version ]; then
        info "Sistema Debian/Ubuntu detectado."
        error "La instalación en sistemas Debian/Ubuntu aún no está implementada."
    elif [ -f /etc/redhat-release ]; then
        info "Sistema Fedora/Red Hat detectado."
        error "La instalación en sistemas Fedora/Red Hat aún no está implementada."
    else
        error "No se pudo detectar un sistema operativo compatible (Arch, Debian/Ubuntu, Fedora/Red Hat)."
    fi

    info "Instalación de dependencias completada."
}

main
