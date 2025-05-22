#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# IMPORT UTILS
source "$SCRIPT_DIR/../utils/color_echos.sh"
source "$SCRIPT_DIR/../utils/helpers.sh"

#======================#
#   Constants          #
#======================#

ROOT_DIR="$HOME"
RUNCOMS_PATH="$HOME/.gir/runcoms"
BACKUP_PATH="$ROOT_DIR/_back.rcs"

#======================#
#   Functions          #
#======================#

_validate_directories() {
  if [ ! -d "$RUNCOMS_PATH" ]; then
    red_echo "Run commands path does not exist:"
    "$RUNCOMS_PATH"
    exit 1
  fi

  if [ ! -d "$BACKUP_PATH" ]; then
    yellow_echo "Creating backup directory:"
    echo "$BACKUP_PATH"
    mkdir -p "$BACKUP_PATH"
  fi
}

_get_runcom_files() {
  ls "$RUNCOMS_PATH" | grep -v -iE "ln\.sh|readme|vundle" | normalize_spaces
}

_backup_file() {
  local src="$1"
  local name="$2"
  local ts
  ts=$(timestamp)
  local dst="$BACKUP_PATH/${name}_${ts}"

  yellow_echo "Backing up:"
  echo $src
  yellow_echo "to:"
  echo $dst
  echo
  cp -a "$src" "$dst"
}

_backup_symlink_target() {
  local link_path="$1"
  local name="$2"
  local target
  target=$(resolve_symlink_target "$link_path")

  if [ -e "$target" ]; then
    _backup_file "$target" "$name"
  else
    red_echo "Warning: Symlink $link_path points to missing file. Skipping backup."
  fi
}

_handle_backup() {
  local path="$1"
  local name="$2"

  if [ -L "$path" ]; then
    _backup_symlink_target "$path" "$name"
  elif [ -e "$path" ]; then
    _backup_file "$path" "$name"
  fi
}

_create_symlink() {
  local src="$1"
  local dest="$2"

  ln -sf "$src" "$dest"
  yellow_echo "Linked:"
  echo "$src -> $dest"
}

_sync_runcom_file() {
  local filename="$1"
  local src="$RUNCOMS_PATH/$filename"
  local dest="$ROOT_DIR/.$filename"

  _handle_backup "$dest" "$filename"
  _create_symlink "$src" "$dest"
}


#======================#
#   Main               #
#======================#


main() {
  yellow_echo "======================"
  echo
  blue_echo "Linking run command files..."
  _validate_directories

  run_commands=$(_get_runcom_files)
  readable_list=$(human_readable_list "$run_commands")

  yellow_echo "Found files:"
  echo "$readable_list"
  echo
  # echo "$run_commands"
  # echo

  for file in $run_commands; do
    _sync_runcom_file "$file"
  done

  echo
  green_echo "Finished!"
}


main "$@"

# -------------------
# #!/bin/bash
#
# normalizeSpaces() {
#   perl -CS -pe 's/\p{Space}/ /g'
# }
#
# ROOT_DIR=$HOME/DELETE_ME
#
# RUNCOMS_PATH=$ROOT_DIR/.rcs/runcoms
#
# if [ ! -d $RUNCOMS_PATH ]; then
#   # mkdir -p $RUNCOMS_PATH
#   echo "Run commands path does not exist: $RUNCOMS_PATH"
#   exit 1
# fi
#
#
# BACKUP_PATH=$ROOT_DIR/_back.rcs
# run_commands=`ls $RUNCOMS_PATH | grep -v "ln.sh" | grep -iv "readme" | grep -iv "Vundle" | perl -CS -pe 's/\p{Space}/ /g'`       # Generate a list of files
# list=`echo $run_commands | perl -CS -pe 's/\p{Space}/, /g' | sed -e 's/, $//'`                   # Generate human-readable list
#
# echo "Found files: $list" && echo
# echo "$run_commands" && echo
#
# if [ ! -d $BACKUP_PATH ]; then
#   mkdir -p $BACKUP_PATH
# fi
#
# cd $RUNCOMS_PATH
# for file in $run_commands; do
#   if [ -a $ROOT_DIR/.$file ]; then
#     mv -f $ROOT_DIR/.$file $BACKUP_PATH/$file
#   fi
#   ln -s $RUNCOMS_PATH/$file $ROOT_DIR/.$file
# done
#
# echo && echo "Finished!"

# --------------------

# # List of runcoms
# runcoms = $( \
#   ls $ROOT_DIR/.rcs/runcoms \
#   | normalizeSpaces
# )
# dotfiles=$ROOT_DIR/.rcs
# backup=$ROOT_DIR/_back.rcs
#
# # Current run_commands directory
# run_commands=$HOME/.rcs/configs
# # Backup run_commands directory
# backup=$ROOT_DIR/DELETE_ME/_back.rcs
#
# files=`ls $run_commands | normalizeSpaces`
#
# # Dot Config location
# CONFIGPATH=$ROOT_DIR/.config
#
# # Generate a list of FILES
# FILES=$( \
#   ls $run_commands \
#   | grep -iv "readme" \
#   | normalizeSpaces
# )
# # Generate human-readable list
# list=$( \
#   echo $FILES \
#   | normalizeSpaces \
#   | sed -e 's/, $//'
# )
#
# echo "Found FILES: $list" && echo
# echo "$FILES" && echo
#
# if [ ! -d $run_commands ]; then
#   mkdir -p $run_commands
# fi
#
# if [ ! -d $backup ]; then
#   mkdir -p $backup
# fi
#
# cd $run_commands
# for dir in $FILES; do
#   if [ -a $CONFIGPATH/$dir ]; then
#     mv -f $CONFIGPATH/$dir $backup/$dir
#   fi
#   ln -s $run_commands/$dir $CONFIGPATH/$dir
# done
#
# echo && echo "Finished!"

# ------------------


# dotfiles=$HOME/.rcs                                             # Current dotfiles directory
# backup=$HOME/_back.rcs                                           # Backup dotfiles directory
# files=`ls $dotfiles | grep -v "ln.sh" | grep -iv "readme" | grep -iv "Vundle" | perl -CS -pe 's/\p{Space}/ /g'`       # Generate a list of files
# list=`echo $files | perl -CS -pe 's/\p{Space}/, /g' | sed -e 's/, $//'`                   # Generate human-readable list
#
# echo "Found files: $list" && echo
# echo "$files" && echo
# if [ ! -d $dotfiles ]; then
#   mkdir -p $dotfiles
# fi
#
# if [ ! -d $backup ]; then
#   mkdir -p $backup
# fi
#
# cd $dotfiles
# for file in $files; do
#   if [ -a $HOME/.$file ]; then
#     mv -f $HOME/.$file $backup/$file
#   fi
#   ln -s $dotfiles/$file $HOME/.$file
# done
#
# echo && echo "Finished!"
