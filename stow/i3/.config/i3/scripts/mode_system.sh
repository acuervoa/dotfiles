#!/bin/bash

# Define the options with icons
options="<span font='FontAwesome'></span> Lock\n<span font='FontAwesome'></span> Logout\n<span font='FontAwesome'></span> Suspend\n<span font='FontAwesome'></span> Hibernate\n<span font='FontAwesome'></span> Reboot\n<span font='FontAwesome'></span> Shutdown"

# Get the chosen option
chosen="$(echo -e "$options" | rofi -dmenu -markup-rows -i -p "System:")"

# Run the corresponding command
case "$chosen" in
    *Lock) ~/.config/i3/scripts/i3lock.sh lock ;;
    *Logout) ~/.config/i3/scripts/i3exit.sh logout ;;
    *Suspend) ~/.config/i3/scripts/i3exit.sh suspend ;;
    *Hibernate) ~/.config/i3/scripts/i3exit.sh hibernate ;;
    *Reboot) ~/.config/i3/scripts/i3exit.sh reboot ;;
    *Shutdown) ~/.config/i3/scripts/i3exit.sh shutdown ;;
    *) exit 1 ;;  # Exit if no valid option is chosen
esac

