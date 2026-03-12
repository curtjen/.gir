#!/bin/bash

# Install Neovim

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install via Homebrew
    echo "Installing Neovim via Homebrew..."
    brew install neovim
    echo "Done!"
else
    # Install via apt-get
    echo "Installing Neovim via apt-get..."
    sudo apt-get install neovim -y
    echo "Done!"
fi

# Symlink the config

echo "Symlinking Neovim config file..."
if [ -f ~/.config/nvim ]; then
    echo "Neovim config file already exists. Backing up..."
    mv ~/.config/nvim ~/_back.rcs/config__nvim
else
    echo "Create Neovim config directory..."
    mkdir ~/.config/nvim
fi

echo "Create symlink..."
#ln -sf ~/.rcs/nvim__init.vim ~/.config/nvim/init.vim
ln -sf ~/.rcs/configs/nvim__init.lua ~/.config/nvim/init.lua

echo "Neovim init file symlinked to ~/.config/nvim/init.lua"
echo "Done!"

echo "Install related packages..."
bash ~/.rcs/scripts/install_ripgrep.sh
echo "Done!"

echo
