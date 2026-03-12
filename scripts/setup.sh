#!/bin/bash

# Install Oh My ZSH
bash $HOME/.rcs/scripts/install_omz.sh
echo

# Set up aliases
bash $HOME/.rcs/scripts/ln.sh
echo

# Set up Vim
bash $HOME/.rcs/scripts/vim_setup.sh
echo

# Set up NVM

bash $HOME/.rcs/scripts/install_nvm.sh
echo

# Install Powerlevel10k Theme
bash $HOME/.rcs/scripts/install_powerlevel10k_theme.sh
echo

# --- MACOS SPECIFIC ---

# if on macos, install the following

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install Homebrew
    bash $HOME/.rcs/scripts/install_homebrew.sh
    echo

    # Install Homebrew packages
    bash $HOME/.rcs/scripts/install_homebrew_packages.sh
    echo

    # Install Window Manager
    # NOTE: This needs to run AFTER the Homebrew install.
    bash $HOME/.rcs/scripts/install_window_manager.sh
    echo
fi

# Insall Neovim stuff
bash ~/.rcs/scripts/install_neovim.sh

# Add a lovely new line after all the scripts finish
echo
