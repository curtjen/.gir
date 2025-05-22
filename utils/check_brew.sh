#!/bin/bash

# Resolve script directory and use it to find utils/colors.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/color_echos.sh"

check_for_homebrew() {
  if [ "$(uname)" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      red_echo "Homebrew not found. Installing Homebrew..."
    else
      green_echo "Homebrew is installed!"
      exit 0
    fi
  else
    red_echo "Homebrew is not supported on this OS."
    exit 1
  fi
}


check_for_homebrew_v2() {
  yellow_echo "Checking for Homebrew..."
  echo

  if [ "$(uname)" = "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
      red_echo "Homebrew not found."
      # echo "false"
      return 1
    else
      green_echo "Homebrew is installed!"
      # echo "true"
      return 0
    fi

  else
    red_echo "Homebrew is not supported on this OS."
    echo
    exit 1
  fi
}
