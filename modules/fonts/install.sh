#!/bin/bash

MODULE_NAME="fonts"
MODULE_DESCRIPTION="Install Powerline fonts"
MODULE_PLATFORMS="macos no_ssh"

install_module() {
  local temp_dir="$HOME/DELETE_ME_fonts"

  log_info "Cloning Powerline fonts repo..."
  git clone https://github.com/powerline/fonts.git "$temp_dir" --depth=1

  log_info "Running font install script..."
  (cd "$temp_dir" && ./install.sh)

  log_info "Cleaning up..."
  rm -rf "$temp_dir"

  log_ok "Powerline fonts installed"
}
