#!/usr/bin/env bash
# USAGE: ./install.sh
# NOTES:
# - All prompts should be answered "y"
# - When zsh is installed, type exit to continue the script
# - nvim will take a couple of start/exit cycles to run correctly, and may dump core
#   the first time. after it seems to be working, denite will be off, so run
#   :checkhealth and follow instructions
# - If it's been a while since this file was updated, versions of any manually
#   downloaded programs should be checked and updated as needed (node, rg, etc.)
#
# Tested on ubuntu 18.04. For 19.04:
# - ripgrep and fzf should be installed by apt-get instead of manually
set -x

# create softlinks to all of the dot files in script directory
PATH_TO_DOT_FILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install curl, git, zsh...
sudo apt-get install curl git zsh python3-pip python3-venv xclip htop iftop multitime jq tmux peek datamash
ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig
# make sure pip points to pip3. possibly unnecessary
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc
ln -sf $PATH_TO_DOT_FILES/.zshenv $HOME/.zshenv

# install custom zsh theme
ln -s $PATH_TO_DOT_FILES/avit.zsh-theme $HOME/.oh-my-zsh/custom/themes/avit.zsh-theme

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install .tmux
# NOTES: in the newly-created ~/.tmux.conf.local:
#   - uncomment the powerline fonts,
#   - uncomment set history-limit to 10000
#   - uncomment set mouse on
#   - set tmux_conf_copy_to_os_clipboard=true
#   - set tmux_conf_new_session_prompt=true
#   - set tmux_conf_24b_colour=true
#   - set tmux_conf_theme_highlight_focused_pane=true
#   - set tmux_conf_new_window_retain_current_path=true
#   - add set repeat-time to 250
#   - add useful plugins
pushd ~
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
popd

# install jog
pushd ~/.local/bin
wget https://github.com/natethinks/jog/blob/cf580bc9387bac17c5cfb0d22bfe75fad72e59fd/jog
chmod u+x jog
popd

# install node/yarn
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
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
sudo apt-get install clangd-9
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100

# install powerline fonts that work with vscode. see
# https://dev.to/mattstratton/making-powerline-work-in-visual-studio-code-terminal-1m7.
# will need to restart X for this to work
wget https://github.com/abertsch/Menlo-for-Powerline/raw/master/Menlo%20for%20Powerline.ttf
mkdir -p ~/.local/share/fonts
mv -f 'Menlo for Powerline.ttf' ~/.local/share/fonts/
sudo fc-cache -vf ~/.local/share/fonts/

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

# install csvkit
pip install csvkit --user

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

# install daml
curl -sSL https://get.daml.com/ | sh

# install nvim
rm -f $HOME/.local/bin/nvim
curl -fLo ~/.local/bin/nvim --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod a+x ~/.local/bin/nvim
ln -sf $HOME/.local/bin/nvim $HOME/.local/bin/vim
mkdir -p $HOME/.config/nvim
ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
ln -sf $PATH_TO_DOT_FILES/noplug.init.vim $HOME/.config/nvim/noplug.init.vim
ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
yarn global add neovim
pip3 install neovim

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

# install pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# install poetry
pipx install poetry

# increase default number of file watchers (for webpack, see
# https://github.com/webpack/docs/wiki/troubleshooting#not-enough-watchers)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# install git credential manager (see
# https://github.com/microsoft/Git-Credential-Manager-Core) and use the Secret
# Service API for github auth (see https://tinyurl.com/hrwh2nsn)
# IMPORTANT: as of this writing, the GCM is in preview status for linux, and
# not all ubuntu releases have apt-get repos. the method below downloads a
# specific .deb package, which will inevitably go out of date. check the GCM
# installation instructions for updates before installing
pushd $(mktemp -d)
curl -fLo gcm.deb https://github.com/microsoft/Git-Credential-Manager-Core/releases/download/v2.0.498/gcmcore-linux_amd64.2.0.498.54650.deb
sudo dpkg -i gcm.deb
popd
bash -c 'git-credential-manager-core configure'
git config --global credential.credentialStore secretservice

# install btop
# NOTE: while btop will be in the path after installation, it won't be
# searchable from the gnome activities menu. per
# https://superuser.com/a/1285686/1264067, adding an app is a bit more
# involved, but since the extra step of starting a terminal isn't a particular
# burden, we'll just stick with that
pushd $(mktemp -d)
# gcc-11 not available as of writing on focal. from
# https://stackoverflow.com/a/67453352/12162258, this is how to get it
sudo apt install build-essential manpages-dev software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
# the rest from https://github.com/aristocratos/btop#installation
# obviously there is some repetition, but apt will correctly ignore it
sudo apt install coreutils sed git build-essential gcc-11 g++-11
git clone https://github.com/aristocratos/btop.git
pushd btop
make
sudo make install
sudo make setuid
popd
popd

# finish up by running a few commands in zsh
./zsh-install.sh
