#!/bin/bash

# # # # #
# Auth: Jiskiras
# Desc: Makes a backup and creates symlinks for any file/folder found in $dotfiles to $HOME
# Date: 02.18.13
# # # # #

dotfiles=$HOME/.rcs                                                                                       # Current dotfiles directory
backup=$HOME/_back.rcs                                                                                     # Backup dotfiles directory
files=`ls $dotfiles | grep -v "ln.sh" | grep -iv "readme" | grep -iv "Vundle" | perl -CS -pe 's/\p{Space}/ /g'`             # Generate a list of files
list=`echo $files | perl -CS -pe 's/\p{Space}/, /g' | sed -e 's/, $//'`                                     # Generate human-readable list

echo "Found files: $list" && echo
echo "$files" && echo
if [ ! -d $dotfiles ]; then
    mkdir -p $dotfiles
fi

if [ ! -d $backup ]; then
    mkdir -p $backup
fi

cd $dotfiles
for file in $files; do
    if [ -a $HOME/.$file ]; then
        mv -f $HOME/.$file $backup/$file
    fi
    ln -s $dotfiles/$file $HOME/.$file
done

echo && echo "Finished!"
