#!/bin/bash
# exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

_install() {
  local commands=(
    "mac:brew install fzf"
    "arch:sudo pacman -S fzf --noconfirm"
    "debian:sudo apt install fzf -y"
  )

  _action() {
    run_install "${commands[@]}"
  }
  do_action _action "Install FZF"
}

main() {
  divider
  title_echo "Installing FZF..."
  _install 
  success_echo "Done!"
}

main "$@"
