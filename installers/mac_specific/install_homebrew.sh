#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../../utils/color_echos.sh"
source "$SCRIPT_DIR/../../utils/check_brew.sh"


install_homebrew() {
  # Install Homebrew
  yellow_echo "Installing Homebrew..."
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

#======================#
#     Main             #
#======================#

main() {
  # Check if Homebrew is installed
  yellow_echo "======================"

  check_for_homebrew
  install_homebrew
  check_for_homebrew

  green_echo "Finished!"
  echo
}

main "$@"

