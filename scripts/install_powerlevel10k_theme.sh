#!/bin/bash

# This script installs the powerlevel10k ZSH theme and symlinks the config file.

echo "Installing powerlevel10k theme..."

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

echo "Powerlevel10k theme installed."

echo "Symlinking powerlevel10k config file..."
if [ -f ~/.p10k.zsh ]; then
    echo "Powerlevel10k config file already exists. Backing up..."
    mv ~/.p10k.zsh ~/_back.rcs/.p10k.zsh
fi
ln -sf ~/.rcs/configs/p10k.zsh ~/.p10k.zsh
echo "Powerlevel10k config file symlinked to ~/.p10k.zsh"
echo "NOTE: You may need to source the theme in your .zshrc file. More details can be found at: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh"
echo "Done!"
