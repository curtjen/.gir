#!/bin/bash
# exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh".sh
source "$SCRIPT_DIR/../utils/delete_progress.sh"

TEMP_DIR="$HOME/DELETE_ME_fonts"

_clone_repo() {
  _action() {
    git clone https://github.com/powerline/fonts.git $TEMP_DIR --depth=1
  }
  do_action _action "Clone font repo" _cleanup
}

_run_install_script() {
  _action() {
    cd $TEMP_DIR
    ./install.sh
  }
  do_action _action "Run install script" _cleanup
}

_cleanup() {
  _action() {
    cd $TEMP_DIR
    cd ..
    delete_progress $TEMP_DIR
  }
  do_action _action "Cleanup"
}

_install() {
  _clone_repo
  _run_install_script
  _cleanup
}

main() {
  divider
  title_echo "Installing fonts..."
  _install
  success_echo "Done!"
}

main "$@"
