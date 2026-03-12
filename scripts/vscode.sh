#!/bin/bash

echo "Creating alias for Visual Studio Code in Drive."
mv $HOME/Library/Application\ Support/Code $HOME/Library/Application\ Support/Code.baccc
mv $HOME/.vscode $HOME/.vscode.baccc
ln -s $HOME/Drive/vscode/Library_Application-Support_Code_User $HOME/Library/Application\ Support/Code && rm -rf $HOME/Library/Application\ Support/Code.baccc
ln -s $HOME/Drive/vscode/dot-vscode $HOME/.vscode && rm -rf $HOME/.vscode.baccc
echo && echo "Finished!"
