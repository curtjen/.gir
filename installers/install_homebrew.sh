#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/check_brew.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

# _verify_install() {
# }

_install_homebrew() {
  # Install Homebrew
  _action() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  }
  do_action _action "Install Homebrew"
}

_install_brewfile() {
  BREWFILE_PATH="$SCRIPT_DIR/../Brewfile"
  # Check if Brewfile exists
  _action() {
    if [ ! -f $BREWFILE_PATH ]; then
      error_echo "Brewfile not found. Exiting..."
      exit 1
    fi
    brew bundle --file "$BREWFILE_PATH"
  }
  do_action _action "Install packages from Brewfile"
}


main() {
  divider

  # check_for_homebrew
  # _install_homebrew
  if ! check_for_homebrew_v2; then
    error_echo "Homebrew is not installed. Installing Homebrew..."
    _install_homebrew
  else
    success_echo "Homebrew is already installed!"
  fi
  _install_brewfile
  success_echo "Homebrew and packages installed successfully!"
}

main "$@"

