#!/bin/bash

# create softlinks to all of the dot files in script directory
PATH_TO_DOT_FILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install curl, git, zsh...
sudo apt-get install curl git zsh python3-pip python-pip xclip fzf ripgrep
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc
ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

# install js-beautify
sudo npm -g install js-beautify
ln -sf $PATH_TO_DOT_FILES/.jsbeautifyrc $HOME/.jsbeautifyrc

# install clangd
sudo apt-get install clang-tools-8
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100

# install powerline fonts. will need to restart X for this to work
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mkdir -p ~/.local/share/fonts
mv -f PowerlineSymbols.otf ~/.local/share/fonts/
sudo fc-cache -vf ~/.local/share/fonts/
mkdir -p ~/.config/fontconfig/conf.d
mv -f 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

# install pynvim
pip3 install --user pynvim
pip install --user pynvim

# install jedi
pip install jedi

# install universal-ctags
sudo snap install universal-ctags

# install nvim
rm -f $HOME/bin/nvim
curl -fLo ~/bin/nvim --create-dirs https://github.com/neovim/neovim/releases/download/v0.4.2/nvim.appimage
chmod +x ~/bin/nvim
ln -sf $HOME/bin/nvim $HOME/bin/vim
mkdir -p $HOME/.config/nvim
ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
sudo npm install -g neovim

