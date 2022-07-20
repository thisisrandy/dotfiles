#!/usr/bin/env bash
# USAGE: ./install.sh
# NOTES:
# - The script will prompt for root priviledges once at the beginning and
#   thenceforth operate unattended
# - After installation, nvim will need to be restarted to run correctly with
#   all plugins. use :checkhealth after restart to verify everything is happy
# - If it's been a while since this file was updated, versions of any manually
#   downloaded programs should be checked and updated as needed (node, rg, etc.)
# TESTED ON: Ubuntu 20.04
set -x

# this will be used in several places
mkdir -p ~/.local/bin

# install/use display drivers (restart needed)
sudo ubuntu-drivers autoinstall
sudo prime-select nvidia

# create softlinks to all of the dot files in script directory
PATH_TO_DOT_FILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install curl, git, zsh...
sudo apt-get -y install curl git zsh xclip htop iftop gcc make \
    multitime jq tmux peek datamash nmap bvi httpie ripgrep fzf
ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig

# install pyenv
curl https://pyenv.run | bash
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# per https://github.com/pyenv/pyenv/wiki#suggested-build-environment,
# we'll want to get an appropriate build environment set up for python
# installations
sudo apt-get -y install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
# now install python. the version will need to be updated in the future
PYTHON_LATEST=3.10.5
pyenv install $PYTHON_LATEST
# and make it the global version
pyenv global $PYTHON_LATEST
# for the rest of the script, it will be convenient to refer to pip concisely
alias pip='python -m pip'
# make sure that pip is up-to-date
pip install --upgrade pip

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
# copy config files
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc
ln -sf $PATH_TO_DOT_FILES/.zshenv $HOME/.zshenv
# and change zsh to default. the install script can do this too, but only
# interactively
type zsh | awk '{print $3}' | xargs -I{} sudo chsh -s {} $USER

# install custom zsh theme
ln -s $PATH_TO_DOT_FILES/avit.zsh-theme $HOME/.oh-my-zsh/custom/themes/avit.zsh-theme

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install .tmux. it's a good idea to sync with gpakosz/.tmux before installing
pushd ~
git clone https://github.com/thisisrandy/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
popd

# install jog
pushd ~/.local/bin
wget https://github.com/natethinks/jog/blob/cf580bc9387bac17c5cfb0d22bfe75fad72e59fd/jog
chmod u+x jog
touch ~/.zsh_history_ext
chmod og-rw ~/.zsh_history_ext
popd

# install node/yarn
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get -y install -y nodejs
npm config set prefix ~/.local # prevents need to sudo for -g
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y update && sudo apt-get -y install yarn

# install clangd
sudo apt-get -y install clangd-9
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100

# install powerline fonts that work with vscode. see
# https://dev.to/mattstratton/making-powerline-work-in-visual-studio-code-terminal-1m7.
# will need to restart X for this to work
wget https://github.com/abertsch/Menlo-for-Powerline/raw/master/Menlo%20for%20Powerline.ttf
mkdir -p ~/.local/share/fonts
mv -f 'Menlo for Powerline.ttf' ~/.local/share/fonts/
sudo fc-cache -vf ~/.local/share/fonts/
# then, the terminal needs to be set to use it. per
# https://ncona.com/2019/11/configuring-gnome-terminal-programmatically/, we
# can do this programmatically
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | \
    awk -F \' '{print $2}'`
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'Menlo for Powerline Regular 11'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-system-font false
# we can also take the opportunity to set a few other settings
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ scrollbar-policy never
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false

# install pynvim
pip install --user pynvim

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

# install go
pushd $(mktemp -d)
curl -LO https://go.dev/dl/go1.18.4.linux-amd64.tar.gz
tar xfz go1.18.4.linux-amd64.tar.gz
sudo mv go /usr/local
rm go1.18.4.linux-amd64.tar.gz
popd

# install shfmt (to ~/go/bin)
pushd $(mktemp -d)
go mod init tmp
go get mvdan.cc/sh/cmd/shfmt
popd

# install bat. per https://askubuntu.com/a/1300824/1014459, on 20.04 this needs
# some special magic
sudo apt-get -y install -o Dpkg::Options::="--force-overwrite" bat
# per https://github.com/sharkdp/bat#on-ubuntu-using-apt, bat might be installed
# as batcat. set up a symlink so fzf can use it as bat
ln -s /usr/bin/batcat ~/.local/bin/bat
# and extras
pushd $(mktemp -d)
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
pip install neovim

# install VS code settings
mkdir -p $HOME/.config/Code/User
ln -sf $PATH_TO_DOT_FILES/vscode-settings.json $HOME/.config/Code/User/settings.json
ln -sf $PATH_TO_DOT_FILES/vscode-keybindings.json $HOME/.config/Code/User/keybindings.json

# install docker
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# give current user permission to run docker (requires restart)
sudo usermod -aG docker $USER

# install poetry
curl -sSL https://install.python-poetry.org/ | python -

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
curl -fLo gcm.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.deb
sudo dpkg -i gcm.deb
popd
bash -c 'git-credential-manager-core configure'
git config --global credential.credentialStore secretservice

# install btop
pushd $(mktemp -d)
# gcc-11 not available as of writing on focal. from
# https://stackoverflow.com/a/67453352/12162258, this is how to get it
sudo apt -y install build-essential manpages-dev software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt -y update
# the rest from https://github.com/aristocratos/btop#installation
# obviously there is some repetition, but apt will correctly ignore it
sudo apt -y install coreutils sed git build-essential gcc-11 g++-11
git clone https://github.com/aristocratos/btop.git
pushd btop
make
sudo make install
sudo make setuid
popd
popd
# finally, create an application so we can launch from the activities menu
# UPDATE: btop appears to do this on its own these days. we'll leave this
# commented for reference
# echo \[Desktop Entry\] > ~/.local/share/applications/Btop.desktop
# echo Name=Btop >> ~/.local/share/applications/Btop.desktop
# echo Exec=/usr/local/bin/btop >> ~/.local/share/applications/Btop.desktop
# echo StartupNotify=true >> ~/.local/share/applications/Btop.desktop
# echo Terminal=true >> ~/.local/share/applications/Btop.desktop
# echo Type=Application >> ~/.local/share/applications/Btop.desktop

# make sure grub shows the full startup sequence
sudo sed -i 's/quiet splash/nomodeset/' /etc/default/grub
sudo update-grub
