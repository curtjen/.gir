#!/bin/bash

MODULE_NAME="wezterm"
MODULE_DESCRIPTION="WezTerm terminal emulator + config"
MODULE_PLATFORMS="macos no_ssh"

install_module() {
  # --- Install WezTerm ---
  if command -v wezterm &>/dev/null; then
    log_skip "WezTerm already installed"
  else
    log_info "Installing WezTerm via Homebrew..."
    brew install --cask wezterm
    log_ok "WezTerm installed"
  fi

  # --- Symlink config ---
  # WezTerm reads ~/.wezterm.lua first, then ~/.config/wezterm/wezterm.lua
  rcs_link "$RCS_DIR/modules/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
}
