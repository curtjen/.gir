#!/bin/bash

MODULE_NAME="homebrew"
MODULE_DESCRIPTION="Homebrew + Brewfile packages"
MODULE_PLATFORMS="macos"

install_module() {
  # --- Install Homebrew ---
  if command -v brew &>/dev/null; then
    log_skip "Homebrew already installed"
  else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_ok "Homebrew installed"
  fi

  # --- Install Brewfile packages ---
  local brewfile="$module_dir/Brewfile"
  if [[ -f "$brewfile" ]]; then
    log_info "Installing Brewfile packages..."
    brew bundle --file="$brewfile"
    log_ok "Brewfile packages installed"
  else
    log_skip "No Brewfile found at $brewfile"
  fi
}
