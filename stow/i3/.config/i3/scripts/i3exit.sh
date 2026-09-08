#!/bin/sh


case "$1" in
    lock)
        ~/.config/i3/scripts/i3lock.sh
        ;;
    logout)
        exec ~/.config/i3/scripts/session-exit.sh
        ;;
    suspend)
        ~/.config/i3/scripts/i3lock.sh && systemctl suspend
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|reboot|shutdown}"
        exit 2
esac

exit 0
