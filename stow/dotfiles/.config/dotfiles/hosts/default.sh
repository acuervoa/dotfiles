#!/usr/bin/env bash
# Host profile: default
#
# This file is sourced by scripts/bootstrap.sh and scripts/rollback.sh.
# It defines which stow packages get installed.

# Packages that stow directly into $HOME
# shellcheck disable=SC2034  # read by bootstrap.sh/rollback.sh via source
HOME_PKGS=(bash git tmux vim bin)

# Packages that include the `.config/` prefix inside their stow package.
# These should be stowed with target $HOME (not $HOME/.config).
# shellcheck disable=SC2034  # read by bootstrap.sh/rollback.sh via source
CONFIG_CORE_PKGS=(atuin blesh lazygit mise nvim yazi)
# shellcheck disable=SC2034  # read by bootstrap.sh/rollback.sh via source
CONFIG_GUI_PKGS=(dunst i3 kitty picom polybar rofi)
