#!/bin/bash

echo "Installing window manager..."

# check if brew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew could not be found. Exiting..."
    echo "Details to install Homebrew: https://brew.sh/"
    exit 1
    # echo "Homebrew could not be found. Installing..."
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

echo "Installing AeroSpace..."
cd ~/
brew install --cask nikitabobko/tap/aerospace

echo "AeroSpace installed."

# symlink the config file
echo "Symlinking AeroSpace config file..."
if [ -f ~/.aerospace.toml ]; then
    echo "AeroSpace config file already exists. Backing up..."
    mv ~/.aerospace.toml ~/_back.rcs/.aerospace.toml
fi

ln -sf ~/.rcs/aerospace.toml ~/.aerospace.toml

echo "AeroSpace config file symlinked to ~/.aerospace.toml"
echo "Done!"
