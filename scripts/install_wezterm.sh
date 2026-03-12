#!/bin/bash

# WEZTerm is installed via Homebrew on macOS.

echo "Installing Wezterm..."

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

echo

echo "Symlinking Wezterm config file..."
if [ -f ~/.wezterm.lua ]; then
    echo "Wezterm config file already exists. Backing up..."
    mv ~/.wezterm.lua ~/_back.rcs/.wezterm.lua
fi
ln -sf ~/.rcs/wezterm.lua ~/.wezterm.lua

echo "Wezterm config file symlinked to ~/.wezterm.lua"
echo "Done!"
echo
