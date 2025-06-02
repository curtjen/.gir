#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

#======================#
#   Constants          #
#======================#

RUNCOMS_PATH="$HOME/.gir/runcoms"
THEME_DIR="$RUNCOMS_PATH/themes"

# _validate_directories() {
#   if [ ! -d "$RUNCOMS_PATH" ]; then
#     # red_echo "Run commands path does not exist:"
#     error_echo "Run commands path does not exist:"
#     "$RUNCOMS_PATH"
#     return 1
#   fi
#
#   if [ -d "$RUNCOMS_PATH/theme/powerlevel10k/powerlevel10k.zsh-theme" ]; then
#     yellow_echo "Theme directory already exists. Exiting..."
#     return 1
#   fi
#   return 0
# }

_validate_directories() {
  if [ ! -d "$RUNCOMS_PATH" ]; then
    error_echo "Run commands path does not exist: $RUNCOMS_PATH"
    return 1
  fi

  if [ -d "$THEME_DIR/powerlevel10k" ]; then
    yellow_echo "Theme directory already exists. Exiting..."
    return 1
  fi
  return 0
}

_backup_existing_theme() {
  if [ -d "$THEME_DIR/powerlevel10k" ]; then
    backup_item "$THEME_DIR/powerlevel10k" "$THEME_DIR/_backups"
  fi
}

_remove_old_theme_dir() {
  if [ -d "$THEME_DIR/powerlevel10k" ]; then
    rm -rf "$THEME_DIR/powerlevel10k"
    echo "Removed old theme directory: $THEME_DIR/powerlevel10k"
  fi
}

_setup() {
  _action() {
    _validate_directories
    theme_exists=$?
    if [ $theme_exists -ne 0 ]; then
      _backup_existing_theme
      _remove_old_theme_dir
    fi
  }
  do_action _action "Setup theme directory"
}

_install() {
  _action() {

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $THEME_DIR/powerlevel10k
    echo "source $THEME_DIR/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
  }
  do_action _action "Install powerlevel10k theme"
}

#======================#
#   Main               #
#======================#


# main() {
#   yellow_echo "======================"
#   echo
#   blue_echo "Installing theme: powerlevel10k..."
#
#   _validate_directories
#   can_install=$?
#
#   if [ $can_install -eq 0 ]; then
#     _install_theme
#   fi
#
#   echo
#   green_echo "Finished!"
#   echo
# }

main() {
  divider
  title_echo "Installing shell theme..."
  _setup
  _install
  # _create_link
  success_echo "Done!"
}


main "$@"
