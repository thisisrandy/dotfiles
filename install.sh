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
sudo apt-get install curl git zsh python3-pip xclip htop
ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig
# make sure pip points to pip3. possibly unnecessary
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc

# install custom zsh theme
ln -s $PATH_TO_DOT_FILES/avit.zsh-theme $HOME/.oh-my-zsh/custom/themes/avit.zsh-theme

# install node/yarn
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
npm config set prefix ~/.local # prevents need to sudo for -g
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

# install js-beautify
yarn global add js-beautify
ln -sf $PATH_TO_DOT_FILES/.jsbeautifyrc $HOME/.jsbeautifyrc

# install flow-bin (for tabnine)
yarn global add flow-bin

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
pip install --user pynvim

# install pyenv
curl https://pyenv.run | bash

# install jedi
pip install jedi --user

# install black
pip install black --user

# install tqdm
pip install tqdm --user

# install jupytext for jupytext.vim
pip install jupytext --user

# install universal-ctags (for tagbar)
sudo snap install universal-ctags
# this line is necessary because of
# https://github.com/universal-ctags/ctags-snap/issues/4
# (shouldn't be in the future)
sudo snap connect universal-ctags:dot-ctags

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
rm -f $HOME/.local/bin/nvim
curl -fLo ~/.local/bin/nvim --create-dirs https://github.com/neovim/neovim/releases/download/v0.4.2/nvim.appimage
chmod a+x ~/.local/bin/nvim
ln -sf $HOME/.local/bin/nvim $HOME/.local/bin/vim
mkdir -p $HOME/.config/nvim
ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
yarn global add neovim

# install VS code settings
mkdir -p $HOME/.config/Code/User
ln -sf $PATH_TO_DOT_FILES/vscode-settings.json $HOME/.config/Code/User/settings.json
ln -sf $PATH_TO_DOT_FILES/vscode-keybindings.json $HOME/.config/Code/User/keybindings.json

# install docker
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io
# give current user permission to run docker (requires restart)
sudo usermod -aG docker $USER

