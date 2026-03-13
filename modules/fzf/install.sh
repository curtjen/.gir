#!/bin/bash

MODULE_NAME="fzf"
MODULE_DESCRIPTION="Fuzzy finder for the terminal"
MODULE_PLATFORMS="all"

install_module() {
  if command -v fzf &>/dev/null; then
    log_skip "fzf already installed ($(fzf --version))"
    return 0
  fi

  log_info "Installing fzf..."

  if [[ "$IS_MACOS" == true ]]; then
    brew install fzf
    log_ok "fzf installed"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y fzf
    log_ok "fzf installed"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y fzf
    log_ok "fzf installed"
  else
    # Fallback: install via fzf's own install script
    log_info "No known package manager — installing fzf via git..."
    local fzf_dir="$HOME/.fzf"
    if [[ -d "$fzf_dir" ]]; then
      log_skip "~/.fzf already exists — skipping git clone"
    else
      git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    fi
    "$fzf_dir/install" --bin --no-update-rc
    log_ok "fzf installed to ~/.fzf/bin/fzf"
    log_info "Add ~/.fzf/bin to your PATH if it is not already there"
  fi
}
