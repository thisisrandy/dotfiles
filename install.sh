#!/bin/bash
# Create softlinks to all of the dot files in script directory
PATH_TO_DOT_FILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
rm $HOME/.zshrc
ln -s $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc
rm $HOME/.jsbeautifyrc
ln -s $PATH_TO_DOT_FILES/.jsbeautifyrc $HOME/.jsbeautifyrc
rm $HOME/.gitconfig
ln -s $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig
rm $HOME/.config/nvim/init.vim
ln -s $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
rm $HOME/.config/nvim/coc-settings.json
ln -s $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
rm $HOME/bin/vim
ln -s $HOME/bin/nvim.appimage $HOME/bin/vim
rm $HOME/bin/nvim
ln -s $HOME/bin/nvim.appimage $HOME/bin/nvim
