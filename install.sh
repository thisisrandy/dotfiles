#!/usr/bin/env bash
# USAGE: ./install.sh
# NOTES:
# - All prompts should be answered "y"
# - When zsh is installed, type exit to continue the script
# - nvim will take a couple of start/exit cycles to run correctly, and may dump core
#   the first time. after it seems to be working, denite will be off, so run
#   :checkhealth and follow instructions
# - If its been a while since this file was updated, versions of any manually
#   downloaded programs should be checked and updated as needed (node, rg, etc.)
#
# Tested on ubuntu 18.04. For 19.04:
# - ripgrep and fzf should be installed by apt-get instead of manually
set -x

# create softlinks to all of the dot files in script directory
PATH_TO_DOT_FILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install curl, git, zsh...
sudo apt-get install curl git zsh python3-pip python-pip xclip htop
ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc

# install node/yarn
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

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

# install pyenv
curl https://pyenv.run | bash

# install jedi
pip install jedi

# install universal-ctags - this snap is broken as of writing. apparently it doesn't
# have access to any files outside of the home directly, including hidden files within
# the home dir, so it's pretty useless and breaks tagbar, which uses tmp files
# build from source instead
# sudo snap install universal-ctags
sudo apt install \
    gcc make \
    pkg-config autoconf automake \
    python3-docutils \
    libseccomp-dev \
    libjansson-dev \
    libyaml-dev \
    libxml2-dev
git clone https://github.com/universal-ctags/ctags.git ~/.ctags
pushd ~/.ctags
./autogen.sh
./configure
make
sudo make install
popd

# install ripgrep
pushd $(mktemp -d)
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
rm ripgrep_11.0.2_amd64.deb
popd

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# install go
pushd $(mktemp -d)
curl -LO https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
tar xfz go1.13.1.linux-amd64.tar.gz
sudo mv go /usr/local
rm go1.13.1.linux-amd64.tar.gz
popd

# install shfmt (to ~/go/bin)
pushd $(mktemp -d)
go mod init tmp
go get mvdan.cc/sh/cmd/shfmt
popd

# install bat
pushd $(mktemp -d)
curl -LO https://github.com/sharkdp/bat/releases/download/v0.12.1/bat-musl_0.12.1_amd64.deb
sudo dpkg -i bat-musl_0.12.1_amd64.deb
rm bat-musl_0.12.1_amd64.deb
# and extras
curl -LO https://github.com/eth-p/bat-extras/archive/master.zip
unzip master.zip
pushd bat-extras-master
sudo env "PATH=$PATH" ./build.sh --install
popd
sudo rm -rf master.zip bat-extras-master # build creates some protected files
popd

# install nvim
rm -f $HOME/bin/nvim
curl -fLo ~/bin/nvim --create-dirs https://github.com/neovim/neovim/releases/download/v0.4.2/nvim.appimage
chmod a+x ~/bin/nvim
ln -sf $HOME/bin/nvim $HOME/bin/vim
mkdir -p $HOME/.config/nvim
ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
sudo npm install -g neovim

# install VS code settings
mkdir -p $HOME/.config/Code/User
ln -sf $PATH_TO_DOT_FILES/vscode-settings.json $HOME/.config/Code/User/settings.json
ln -sf $PATH_TO_DOT_FILES/vscode-keybindings.json $HOME/.config/Code/User/keybindings.json

