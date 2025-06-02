#!/bin/bash

#======================#
#   UTILS              #
#======================#

normalize_spaces() {
  perl -CS -pe 's/\p{Space}/ /g'
}

timestamp() {
  date "+%Y-%m-%d_%H-%M-%S"
}

human_readable_list() {
  echo "$1" | perl -CS -pe 's/\p{Space}/, /g' | sed -e 's/, $//'
}

resolve_path() {
  readlink -f "$1"
}

# This function takes a string as input and prints it with a status prefix.
# It is used to indicate the status of an operation, such as "Backing up" or "Creating symlink".
# # Usage:
# # backup_file <source_path> <backup_name> <backup_directory>
# # It prints the source and destination paths for the backup operation.

backup_file() {
  local src="$1"
  local name="$2"
  local backup_dir="$3"
  local ts
  ts=$(timestamp)
  local dst="$backup_dir/${name}_${ts}"

  status_echo "Backing up:"
  echo $src
  status_echo "to:"
  echo $dst
  echo
  cp -a "$src" "$dst"
}

# This function checks if the given symlink points to a valid file and backs it up if it does.
# It takes two arguments: the symlink path and a name for the backup file.
# # If the target of the symlink does not exist, it will print a warning message.
# # Usage:
# # backup_symlink_target <symlink_path> <backup_name> <backup_directory>

backup_symlink_target() {
  local link_path="$1"
  local name="$2"
  local backup_dir="$3"
  local target
  target=$(resolve_path "$link_path")

  if [ -e "$target" ]; then
    backup_file "$target" "$name" "$backup_dir"
  else
    warn_echo "Warning: Symlink $link_path points to missing file. Skipping backup."
  fi
}

# This function takes a file path and a name as arguments.
# It checks if the file exists and backs it up to a specified backup directory.
# # Usage:
# # handle_backup <file_path> <backup_name> <backup_directory>
# # It will create a backup with a timestamp in the format <backup_name>_<timestamp>.

handle_backup() {
  local path="$1"
  local name="$2"
  local backup_dir="$3"

  if [ -L "$path" ]; then
    backup_symlink_target "$path" "$name" "$backup_dir"
  elif [ -e "$path" ]; then
    echo "path: $path"
    echo "name: $name"
    echo "backup_dir: $backup_dir"
    # backup_file "$path" "$name" "$backup_dir"
  fi
}

# This function creates a symbolic link from the source file to the destination.
# # It resolves the source path to its absolute path and then creates a symlink.
# # Usage:
# # create_symlink <source_path> <destination_path>
# # It uses `ln -sf` to create the symlink, which means it will forcefully overwrite any existing symlink or file at the destination.
# # It also prints a success message indicating the source and destination of the symlink.

create_symlink() {
  local src=$(resolve_path "$1")
  local dest="$2"

  ln -sfn "$src" "$dest"
  success_echo "Linked:"
  echo "$src -> $dest"
}

check_backup_location() {
  local backup_location="$1"

  if [ ! -d "$backup_location" ]; then
    warn_echo "Warning: Backup location $backup_location does not exist. Creating it."
    mkdir -p "$backup_location"
  fi

  if [ ! -w "$backup_location" ]; then
    error_echo "Error: Backup location $backup_location is not writable."
    exit 1
  fi
}

backup_item() {
  local item_path="$1"
  local backup_location="$2"

  check_backup_location "$backup_location"

  if [ -e "$item_path" ]; then
    local src=$(readlink -f "$item_path")
    local name=$(basename "$item_path")
    local ts
    ts=$(timestamp)
    local dst="$backup_location/${name}_${ts}"

    status_echo "Backing up:"
    echo $src
    status_echo "to:"
    echo $dst
    echo
    cp -a "$src" "$dst"

    # backup_file "$target" "$name" "$backup_location"
  else
    warn_echo "Warning: $item_path does not exist. Skipping backup."
  fi



  # local src="$1"
  # local name="$2"
  # local backup_dir="$3"
  # local ts
  # ts=$(timestamp)
  # local dst="$backup_dir/${name}_${ts}"
  #
  # status_echo "Backing up:"
  # echo $src
  # status_echo "to:"
  # echo $dst
  # echo
  # cp -a "$src" "$dst"
  #
    



  # if [ -L "$path" ]; then
  #   backup_symlink_target "$path" "$name" "$backup_dir"
  # elif [ -e "$path" ]; then
  #   backup_file "$path" "$name" "$backup_dir"
  # else
  #   warn_echo "Warning: $path does not exist. Skipping backup."
  # fi
}

# This function prints a status message to indicate the current operation.
# # It is used to provide feedback during the execution of scripts, such as when creating backups or symlinks.
# # Usage:
# # run_install <commands>
# # It takes an associative array of commands for different platforms and executes the appropriate command based on the detected platform.

OLD__run_install() {
  declare -A commands=("${!1}")

  # Detect platform
  if [[ "$OSTYPE" == "darwin"* ]]; then
    platform="mac"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "${ID,,}" in
      arch)
        platform="arch"
        ;;
      debian|ubuntu)
        platform="debian"
        ;;
      *)
        platform="$ID"
        ;;
    esac
  else
    echo "Unsupported OS"
    return 1
  fi

  if [[ -n "${commands[$platform]}" ]]; then
    echo "Running install command for $platform:"
    eval "${commands[$platform]}"
  else
    echo "No install command defined for platform: $platform"
    return 1
  fi
}

# This function runs the install command based on the platform detected.
# # It takes an array of strings where each string is in the format "platform:command".
# # Usage:
# # run_install ("mac:brew install ripgrep" "arch:sudo pacman -S ripgrep" "debian:sudo apt-get install ripgrep -y")
# # It detects the platform (macOS, Arch Linux, Debian/Ubuntu) and executes the corresponding command.

run_install() {
  local platform=""
  # "$@" used below to access all passed arguments as an array

  # Detect platform
  if [[ "$OSTYPE" == "darwin"* ]]; then
    platform="mac"
  elif command -v pacman >/dev/null 2>&1; then
    platform="arch"
  elif command -v apt-get >/dev/null 2>&1; then
    platform="debian"
  else
    echo "Unsupported OS"
    return 1
  fi

  # Loop over passed arguments (entries in array)
  for entry in "$@"; do
    key="${entry%%:*}"     # Before first colon
    value="${entry#*:}"    # After first colon

    if [[ "$key" == "$platform" ]]; then
      echo "Running install command for $platform:"
      eval "$value"
      return 0
    fi
  done

  echo "No install command found for platform: $platform"
  return 1
}

do_action() {
  local action="$1"
  local message="$2"
  local cleanup="$3"

  status_echo "$message..."

  if ! $action; then
    error_echo "Failed to execute action: $message"

    if [ -n "$cleanup" ]; then
      status_echo "Running cleanup..."
      $cleanup || error_echo "Cleanup failed."
    fi

    exit 1
  fi
  success_echo "$message completed successfully."
}
