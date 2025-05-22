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

resolve_symlink_target() {
  readlink -f "$1"
}

