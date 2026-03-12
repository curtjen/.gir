#!/bin/bash

# Install Ripgrep

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install via Homebrew
    echo "Installing Ripgrep via Homebrew..."
    brew install ripgrep
    echo "Done!"
else
    # Install via apt-get
    echo "Installing Neovim via apt-get..."
    sudo apt-get install ripgrep -y
    echo "Done!"
fi

echo
