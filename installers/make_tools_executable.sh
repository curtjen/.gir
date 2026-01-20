#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

TOOLS_PATH="$HOME/.gir/tools"

# _validate_directories() {
#   if [ ! -d "$TOOLS_PATH" ]; then
#       error_echo "Run commands path does not exist: $TOOLS_PATH"
#     return 1
#   fi
#   return 0
# }

make_executable() {
  local file="$1"
  chmod +x "$file"
}

main() {
  divider
  title_echo "Making all files in tools directory executable..."

  local count=0

  for file in "$TOOLS_PATH"/*; do
    # Skip if it's this script or not a regular file
    if [[ "$file" == "$TOOLS_PATH/$(basename "$0")" ]] || [[ ! -f "$file" ]]; then
      continue
    fi

    _action() { make_executable "$file"; }
    do_action _action "Setting executable: $(basename "$file")"
    ((count++))
  done

  if [ $count -eq 0 ]; then
    warn_echo "No regular files to make executable in $TOOLS_PATH."
  else
    success_echo "Made $count file(s) executable in $TOOLS_PATH."
  fi
}

main "$@"
