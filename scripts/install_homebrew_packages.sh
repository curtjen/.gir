#!/bin/bash

echo "Installing Homebrew packages..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew could not be found. Exiting..."
    echo "Details to install Homebrew: https://brew.sh/"
    exit 1
fi
echo "Homebrew is already installed."

# Check if Brewfile exists
echo "Checking for Brewfile..."
if [ ! -f ~/.rcs/Brewfile ]; then
    echo "Brewfile not found. Exiting..."
    exit 1
fi

# Install packages from Brewfile
echo "Installing packages from Brewfile..."
brew bundle --file ~/.rcs/Brewfile
echo "Packages installed from Brewfile."
echo "Done!"
