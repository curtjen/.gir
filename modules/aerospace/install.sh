#!/bin/bash

MODULE_NAME="aerospace"
MODULE_DESCRIPTION="AeroSpace tiling window manager"
MODULE_PLATFORMS="macos no_ssh"

install_module() {
  # --- Install AeroSpace ---
  if command -v aerospace &>/dev/null; then
    log_skip "AeroSpace already installed"
  else
    log_info "Installing AeroSpace via Homebrew..."
    brew install --cask nikitabobko/tap/aerospace
    log_ok "AeroSpace installed"
  fi

  # --- Symlink config ---
  local config_file="$RCS_DIR/modules/aerospace/aerospace.toml"
  if [[ -f "$config_file" ]]; then
    rcs_link "$config_file" "$HOME/.aerospace.toml"
  else
    log_skip "No aerospace.toml found — add one to modules/aerospace/ to enable"
  fi
}
