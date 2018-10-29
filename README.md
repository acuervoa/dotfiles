# Dotfiles

These are my dotfiles. Take anything you want, but at your own risk.

It targets macOS systems. This installation delete all contents from dotfiles located in $HOME directory

## Install
This will clone (using `git`), or download (using `curl` or `wget`), this repo to `~/.dotfiles`. Alternatively, clone manually into the desired location:

```
git clone https://github.com/acuervoa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
.\install.sh
```

Use the `install.sh` file to install everything and link the resources from the **`$HOME`** directory to the nested dotfiles.


## Packages

* .gitconfig and .gitignore files. For local configuration you need a `~/.gitconfig_local` with this information:

```
[user]
    email = <your email address>
    name = <your name> 
```

* [Hammerspoon](https://www.hammerspoon.org/) initial configuration. KeyBindings and windows management. More information [here](./hammerspoon)
* [RainbowBrite Theme](https://github.com/Bash-it/bash-it/tree/master/themes/rainbowbrite) from [Bash_it](https://github.com/Bash-it/bash-it) framework.
* [Vim](https://www.vim.org/) configuration and bundles submodules. More information [here](./vim/)
* [Brewfiles](https://brew.sh) Include brew, cask and mas installations. More information [here](./Brewfile)


## Exernal submodules

 *  [dotbot](https://github.com/anishathalye/dotbot) A tool that bootstraps your dotfiles
 *  [dotbot brewfile](https://github.com/sobolevn/dotbot-brewfile) Install brew packages with dotbot: bundle style!
 *  [vim pathogen](https://github.com/tpope/vim-pathogen) pathogen.vim: manage your runtimepath

## Credits

Many thanks :

- to the [dotfile community](https://dotfiles.github.io)
- to [Webpro](https://github.com/webpro) and his [awesome](https://github.com/webpro/awesome-dotfiles) list

