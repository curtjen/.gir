#!/bin/bash
# exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

ROOT_DIR="$HOME"
RUNCOMS_PATH="$SCRIPT_DIR/../runcoms"
BACKUP_PATH="$ROOT_DIR/_back.rcs"

_install_zsh() {
  local commands=(
    "arch:sudo pacman -Sy --noconfirm zsh"
    "debian:apt install -y zsh"
    # macOS has ZSH pre-intalled
  )
  _action() {
    if ! which zsh >/dev/null 2>&1; then
      run_install "${commands[@]}"
    fi
  }
  do_action _action "Install ZSH"
}

# _validate_directories() {
#   if [ ! -d "$RUNCOMS_PATH" ]; then
#     red_echo "Run commands path does not exist:"
#     "$RUNCOMS_PATH"
#     exit 1
#   fi
#
#   if [ ! -d "$BACKUP_PATH" ]; then
#     yellow_echo "Creating backup directory:"
#     echo "$BACKUP_PATH"
#     mkdir -p "$BACKUP_PATH"
#   fi
# }

_get_runcom_files() {
  ls "$RUNCOMS_PATH" | grep -v -iE "ln\.sh|readme|vundle|themes" | normalize_spaces
}

_sync_runcom_file() {
  local filename="$1"
  local src="$RUNCOMS_PATH/$filename"
  local dest="$ROOT_DIR/.$filename"

  _action() {
    handle_backup "$dest" "$filename" "$BACKUP_PATH"
    create_symlink "$src" "$dest"
  }
  do_action _action "Linking $filename"
}

_install() {
  _action() {
    run_commands=$(_get_runcom_files)
    for file in $run_commands; do
      _sync_runcom_file "$file"
    done
  }
  do_action _action "Install shell stuff"
}

main() {
  divider
  title_echo "Installing shell stuff..."
  _install_zsh
  _install 
  success_echo "Done!"
}

main "$@"
