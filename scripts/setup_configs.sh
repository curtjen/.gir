#!/bin/bash

normalizeSpaces() {
  perl -CS -pe 's/\p{Space}/ /g'
}
# Current configDirs directory
configDirs=$HOME/.rcs/configs
# Backup configDirs directory
backup=$HOME/.config/_back.rcs
# Dot Config location
CONFIGPATH=$HOME/.config

# Generate a list of directories
directories=$( \
  ls $configDirs \
  | grep -iv "readme" \
  | normalizeSpaces
)
# Generate human-readable list
list=$( \
  echo $directories \
  | normalizeSpaces \
  | sed -e 's/, $//'
)

echo "Found directories: $list" && echo
echo "$directories" && echo

if [ ! -d $configDirs ]; then
    mkdir -p $configDirs
fi

if [ ! -d $backup ]; then
    mkdir -p $backup
fi

cd $configDirs
for dir in $directories; do
    if [ -a $CONFIGPATH/$dir ]; then
        mv -f $CONFIGPATH/$dir $backup/$dir
    fi
    ln -s $configDirs/$dir $CONFIGPATH/$dir
done

echo && echo "Finished!"
