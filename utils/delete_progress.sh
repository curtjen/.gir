#!/bin/bash

# IMPORT UTILS
source "$(dirname "$0")/../utils/color_echos.sh"
source "$(dirname "$0")/../utils/helpers.sh"

OLD__delete_progress() {
  TARGET_DIR="$1"

  if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Directory '$TARGET_DIR' does not exist."
    exit 1
  fi

  # Get the list of all files and directories
  mapfile -t ITEMS < <(find "$TARGET_DIR" -depth)

  TOTAL=${#ITEMS[@]}
  COUNT=0

  echo "Deleting contents of '$TARGET_DIR'..."

  for ITEM in "${ITEMS[@]}"; do
    rm -rf "$ITEM"
    ((COUNT++))

    # Display progress
    PERCENT=$(( COUNT * 100 / TOTAL ))
    FILLED=$(( PERCENT / 2 ))
    EMPTY=$(( 50 - FILLED ))
    BAR=$(printf "%${FILLED}s" | tr ' ' '#')
    BAR+=$(printf "%${EMPTY}s" | tr ' ' '-')

    printf "\r[%s] %d%%" "$BAR" "$PERCENT"
  done

  echo -e "\nDeletion complete."
}

delete_progress() {
  TARGET_DIR="$1"

  if [[ ! -d "$TARGET_DIR" ]]; then
    error_echo "Directory '$TARGET_DIR' does not exist."
    exit 1
  fi

  # Read file list into an array
  ITEMS=()
  while IFS= read -r line; do
    ITEMS+=("$line")
  done < <(find "$TARGET_DIR" -depth)

  TOTAL=${#ITEMS[@]}
  COUNT=0

  status_echo "Deleting contents of '$TARGET_DIR'..."

  for ITEM in "${ITEMS[@]}"; do
    rm -rf "$ITEM"
    ((COUNT++))

    PERCENT=$(( COUNT * 100 / TOTAL ))
    FILLED=$(( PERCENT / 2 ))
    EMPTY=$(( 50 - FILLED ))
    BAR=$(printf "%${FILLED}s" | tr ' ' '#')
    BAR+=$(printf "%${EMPTY}s" | tr ' ' '-')

    printf "\r[%s] %d%%" "$BAR" "$PERCENT"
  done

  echo
  success_echo "\nDeletion complete!"
}
