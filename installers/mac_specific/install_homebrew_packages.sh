#!/bin/bash
exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../../utils/color_echos.sh"
source "$SCRIPT_DIR/../../utils/check_brew.sh"

#======================#
#     Functions        #
#======================#

_install_brewfile() {
  # Install packages from Brewfile
  yellow_echo "Installing packages from Brewfile..."
  echo

  echo "brew bundle --file ~/.gir/Brewfile"

  green_echo "Packages installed from Brewfile."
  echo "Done!"
}

#======================#
#     Main             #
#======================#

main() {
  # Check if Homebrew is installed
  yellow_echo "======================"
  blue_echo "Installing Homebrew packages..."

  # TODO: Fix check_for_homebrew so it doesn't exit early
  # check_for_homebrew
  check_for_homebrew_v2
  # is_homebrew_installed=$(check_for_homebrew_v2)
  is_homebrew_installed=$?
  # if [ "$is_homebrew_installed" == "true" ]; then
  if [ $is_homebrew_installed -eq 0 ]; then
    _install_brewfile
  fi
  # check_for_homebrew
  # is_homebrew_installed=$(check_for_homebrew_v2)

  green_echo "Finished!"
  echo
}

main "$@"

