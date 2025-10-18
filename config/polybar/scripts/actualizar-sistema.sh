#!/bin/bash

LOG_FILE="$HOME/.cache/yay-update.log"
MONITOR=$(xdotool getmouselocation --shell | grep SCREEN | cut -d= -f2)
DISPLAY=:0 XDG_CURRENT_DESKTOP=i3 notify-send "Actualizacion del sistema" "Iniciando actuailzación..." -i system-software-update

yay -Syu --sudoloop --noconfirm | tee "$LOG_FILE"

if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    DISPLAY=:0 XDG_CURRENT_DESKTOP=i3 notify-send "Actualización completa" "El sistema se ha actualizado correctamente." -i checkbox-checked
else
    DISPLAY=:0 XDG_CURRENT_DESKTOP=i3 notify-send "Error en la actualización" "Revisa el log en $LOG_FILE" -i dialog-error
fi
