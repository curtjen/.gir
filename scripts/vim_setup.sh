#!/bin/bash
vimbackupdirs=(.backup .swp .undo) # VIM backup directories

cd $HOME/.rcs/vim
for dir in ${vimbackupdirs[@]}; do
    if [ ! -d $dir ]; then
        mkdir $dir
    fi
done

git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +PluginInstall +qall
