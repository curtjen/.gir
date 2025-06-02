#!/bin/bash
# exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

_install() {
  local commands=(
    "mac:brew install neovim"
    "arch:sudo pacman -S neovim --noconfirm"
    "debian:sudo apt-get install neovim=0.11.0 -y"
  )
  status_echo "Installing Neovim..."
  run_install "${commands[@]}" || {
    error_echo "Failed to install Neovim."
    exit 1
  }
  success_echo "Neovim installed successfully."
}

_backup_config() {
  status_echo "Backing up Neovim config directory..."

  if [ -f $HOME/.config/nvim ]; then
    status_echo "Neovim config file already exists. Backing up..."

    backup_item $HOME/.config/nvim $HOME/.config/_back
  fi
}

_check_config_dir() {
  if [ ! -d "$config_target" ]; then
    status_echo "Creating Neovim config directory..."
    mkdir -p "$config_directory"
  fi
}

_create_link() {
  config_source="$(resolve_path "$SCRIPT_DIR/../configs/nvim")"
  config_directory="$HOME/.config"
  config_target="$config_directory/nvim"

  _backup_config
  _check_config_dir

  _action() {
    ln -sfn "$config_source" "$config_target"
  }

  do_action _action "Create symlink"

  success_echo "Neovim config installed at ${config_target}"
}

main() {
  divider
  title_echo "Installing Neovim..."
  _install
  _create_link
  success_echo "Done!"
}

main "$@"
