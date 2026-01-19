# Directory Overview

This repository contains a comprehensive set of dotfiles for an Arch Linux-based development environment, designed for productivity and a consistent user experience across tools like i3, tmux, and NeoVim, all themed with Catppuccin Mocha.

The project has been refactored to use **GNU Stow** for managing symlinks, which simplifies the setup process and makes the repository structure more declarative. The bootstrapping and rollback scripts are now wrappers around `stow`, while preserving the backup and restore functionality.

# Key Files and Directories

*   `stow/`: The core directory containing all the configurations, organized into "packages" that `stow` can manage. Each subdirectory in `stow/` corresponds to a piece of software (e.g., `bash`, `nvim`, `i3`).
    *   `stow/bash/`: Contains shell configurations like `.bashrc`. These are stowed directly to `$HOME`.
    *   `stow/nvim/`: Contains the NeoVim configuration. This package is stowed to `$HOME/.config`.
    *   The structure inside each package directory mirrors the target directory structure in your home directory.
*   `scripts/bootstrap.sh`: The primary script for setting up the dotfiles. It uses `stow` to create the symbolic links and backs up any existing files that would be overwritten.
*   `scripts/rollback.sh`: A script to reverse the actions of `bootstrap.sh`. It uses `stow` to remove the symlinks and can restore the original backed-up dotfiles.
*   `scripts/install_deps.sh`: A script to install necessary system dependencies for Arch Linux.
*   `README.md`: The main documentation for the repository.
*   `.backups/`: Directory where timestamped backups of existing dotfiles are stored during the bootstrap process.
*   The old `bash/`, `config/`, `git/`, `tmux/`, and `vim/` directories are now empty or have been removed, as their contents have been moved to the `stow/` directory.

# Usage

The primary way to use this repository is through the new `stow`-based `bootstrap.sh` and `rollback.sh` scripts.

*   **Dependencies**: Before bootstrapping, install the necessary packages by running:
    ```bash
    bash ./scripts/install_deps.sh
    ```
*   **Bootstrapping:** To set up the dotfiles, run the `bootstrap.sh` script. It's recommended to perform a dry run first:
    ```bash
    bash ./scripts/bootstrap.sh --dry-run
    ```
    This will show you which files would be backed up and which symlinks would be created. To apply the changes:
    ```bash
    bash ./scripts/bootstrap.sh
    ```
*   **Rolling Back:** To undo the setup, the `rollback.sh` script can be used. It will remove all the symlinks created by `stow`. If a backup was created, it can also restore the previous configuration. To roll back and restore the last backup:
    ```bash
    bash ./scripts/rollback.sh latest
    ```

# Secrets Management and Customization

This repository has a system for managing secrets (like API keys) and machine-specific customizations without committing them to Git.

*   **Mechanism**: Create a file with a `_local` suffix (e.g., `.bashrc_local`, `.gitconfig_local`).
*   **Git Ignore**: These `*_local` files are automatically ignored by Git.
*   **Loading**: The main configuration files (like `.bashrc` and `.gitconfig`) are set up to automatically include and load these `_local` files if they exist.
*   **Use Cases**:
    *   `~/.gitconfig_local`: For your personal `[user]name` and `email`.
    *   `~/.bashrc_local`: For exporting secret environment variables (`export GITHUB_TOKEN=...`) or defining private aliases.