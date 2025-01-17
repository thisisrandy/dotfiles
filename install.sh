#!/usr/bin/env bash
# USAGE: ./install.sh
# NOTES:
# - The script will prompt for root priviledges once at the beginning and
#   thenceforth operate unattended. DO NOT RUN AS ROOT
# - After installation, nvim will need to be restarted to run correctly with
#   all plugins. use :checkhealth after restart to verify everything is happy
# - If it's been a while since this file was updated, any explicitly-specified
#   program versions should be checked and updated as needed (python, node, rg,
#   etc.)
# - For unknown reasons, after the github credential manager is installed, it
#   sometimes takes two tries to get it to ask for authentication. If auth
#   fails, just try again and it should work
# - Handbrake is not available until after a system restart
# TESTED ON: Ubuntu 20.04

if [ $USER = root ]; then
    echo This script should not be run as root.
    echo Please run it normally and priviledges will be escalated as needed
    exit 1
fi
set -x

# this will be used in several places
mkdir -p ~/.local/bin

# install/use display drivers (restart needed)
sudo ubuntu-drivers autoinstall
sudo prime-select nvidia

# we'll be creating softlinks in various locations to several files in the
# script directory. per e.g. https://stackoverflow.com/a/246128/12162258, this
# captures said directory
PATH_TO_DOT_FILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# install curl, git, zsh...
sudo apt-get -y install curl git zsh xclip htop iftop gcc make \
    multitime jq tmux peek datamash nmap bvi httpie ripgrep \
    gnome-weather gnome-tweaks tree mkvtoolnix perl-doc fortunes \
    cowsay at linux-tools-common linux-tools-generic ranger sshfs \
    figlet whois default-jre moreutils xsel

ln -sf $PATH_TO_DOT_FILES/.gitconfig $HOME/.gitconfig
ln -sf $PATH_TO_DOT_FILES/rc.conf $HOME/.config/ranger/rc.conf

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
# then install some useful packages
pip install --user wheel
pip install --user black tqdm jupytext csvkit ipython numpy matplotlib thefuck pipx nvitop

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
# copy config files
ln -sf $PATH_TO_DOT_FILES/.zshrc $HOME/.zshrc
ln -sf $PATH_TO_DOT_FILES/.zshenv $HOME/.zshenv
# change zsh to default. the install script can do this too, but only
# interactively.
# UPDATE: type may specify that an executable is hashed, which screws up the
# below (see https://askubuntu.com/a/446583/1014459 for what this means). which
# will do no such thing, so it's more reliable for this particular bit of
# automation
# type zsh | awk '{print $3}' | xargs -I{} sudo chsh -s {} $USER
which zsh | xargs -I{} sudo chsh -s {} $USER
# and then run zsh-install for any additional steps in the oh-my-zsh context
./zsh-install.sh

# install powerlevel10k config
ln -s $PATH_TO_DOT_FILES/.p10k.zsh $HOME/.p10k.zsh

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install zplug. zplug is unacceptably slow to start on my machine. I may
# reenable this in the future after an upgrade
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# install .tmux. it's a good idea to sync with gpakosz/.tmux before installing
pushd ~
git clone https://github.com/thisisrandy/.tmux.git
ln -s -f .tmux/.tmux.conf .tmux/.tmux.conf.local .
popd

# install node/yarn
curl -sL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt-get -y install -y nodejs
npm config set prefix ~/.local # prevents need to sudo for -g
npm install --global yarn

# install clangd
sudo apt-get -y install clangd
# I previously had this installing clangd-9, but I'm not sure why (jammy is at
# v14, so v9 is pretty old). I'm leaving this here as a reminder that I might
# have had a legitimate reason
# sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100

# install powerline fonts that work with vscode. chosen from the selection at
# https://www.nerdfonts.com/font-downloads
pushd $(mktemp -d)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/UbuntuMono.zip
unzip UbuntuMono.zip
mkdir -p ~/.local/share/fonts
mv -f UbuntuMonoNerdFont-Regular.ttf ~/.local/share/fonts/
popd
sudo fc-cache -vf ~/.local/share/fonts/
# then, the terminal needs to be set to use it. per
# https://ncona.com/2019/11/configuring-gnome-terminal-programmatically/, we
# can do this programmatically. Note that if the font name of the install ttf
# is unclear, we can run fc-list | less and search for the ttf file name
GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default |
    awk -F \' '{print $2}')
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'UbuntuMono Nerd Font Regular 12'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-system-font false

# gnome-terminal in jammy doesn't seem to fully support the system theme, so we
# need to turn it off and select a scheme explicitly
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
# this is the same as the tango dark built-in. it doesn't appear there's an
# option to set a built-in via gsettings, but we can replicate its result
# easily enough
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color "rgb(46,52,54)"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ foreground-color "rgb(211,215,207)"
# this is solarized with the palette entry 8 changed to gray
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ palette "['rgb(7,54,66)', 'rgb(220,50,47)', 'rgb(184,187,38)', 'rgb(181,137,0)', 'rgb(131,165,152)', 'rgb(211,54,130)', 'rgb(42,161,152)', 'rgb(238,232,213)', 'rgb(85,87,83)', 'rgb(203,75,22)', 'rgb(88,110,117)', 'rgb(101,123,131)', 'rgb(131,148,150)', 'rgb(108,113,196)', 'rgb(147,161,161)', 'rgb(253,246,227)']"

# we can also take the opportunity to set a few other settings
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ scrollbar-policy never
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.desktop.interface clock-format 12h
# this screws with multiple vim plugins (breaks <C-...> mappings) so best to
# leave it off
gsettings set org.gnome.desktop.interface locate-pointer false
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700 # the least warm possible

# install go
pushd $(mktemp -d)
curl -LO https://go.dev/dl/go1.18.4.linux-amd64.tar.gz
tar xfz go1.18.4.linux-amd64.tar.gz
sudo mv go /usr/local
PATH=/usr/local/go/bin:$PATH
rm go1.18.4.linux-amd64.tar.gz
popd

# install shfmt (to ~/go/bin)
pushd $(mktemp -d)
go mod init tmp
go get mvdan.cc/sh/cmd/shfmt
popd

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install bat. per https://askubuntu.com/a/1300824/1014459, on 20.04 this needs
# some special magic
# sudo apt-get -y install -o Dpkg::Options::="--force-overwrite" bat
# the version of bat that apt uses for 20.04 throws an error when opening files
# inside a git repo. see
# https://github.com/sharkdp/bat/issues/2317#issuecomment-1248343739. we can
# just manually install the latest version instead
pushd $(mktemp -d)
wget https://github.com/sharkdp/bat/releases/download/v0.22.1/bat_0.22.1_amd64.deb
sudo dpkg -i bat_0.22.1_amd64.deb
# per https://github.com/sharkdp/bat#on-ubuntu-using-apt, bat might be installed
# as batcat. set up a symlink so fzf can use it as bat
command -v bat || ln -s /usr/bin/batcat ~/.local/bin/bat
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
pushd $HOME/.local/bin
curl -fLo nvim https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim
ln -sf nvim vim
# NOTE: nightly is needed for all treesitter features to work properly
curl -fLo nvim.nightly https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x nvim.nightly
popd
# My old setup for reference
# mkdir -p $HOME/.config/nvim
# ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
# ln -sf $PATH_TO_DOT_FILES/noplug.init.vim $HOME/.config/nvim/noplug.init.vim
# ln -sf $PATH_TO_DOT_FILES/ts.init.vim $HOME/.config/nvim/ts.init.vim
# ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
# LazyNvim setup
ln -sf $PATH_TO_DOT_FILES/lazy-nvim-config $HOME/.config/nvim
yarn global add neovim
# create a virtual env specifically for nvim and install the relevant packages
# in it. init.vim must specify g:python3_host_prog pointing to bin/python in
# the vevn
pyenv virtualenv $PYTHON_LATEST neovim
pyenv activate neovim
pip install wheel
pip install neovim
pyenv deactivate

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
poetry config virtualenvs.in-project true

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
# configuration
perl -pi -e 's/(update_ms = )\d+/${1}1000/' ~/.config/btop/btop.conf
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

# install zotero
pushd $(mktemp -d)
wget https://download.zotero.org/client/release/6.0.10/Zotero-6.0.10_linux-x86_64.tar.bz2
tar xf Zotero-6.0.10_linux-x86_64.tar.bz2
wget https://www.zotero.org/support/_media/logo/zotero_128x128x32.png
mv zotero_128x128x32.png Zotero_linux-x86_64/
sed -i 's@zotero\.ico@'"$HOME"'/.local/standalone/Zotero_linux-x86_64/zotero_128x128x32.png@' \
    Zotero_linux-x86_64/zotero.desktop
mkdir -p ~/.local/standalone
mv Zotero_linux-x86_64 ~/.local/standalone/
ln -s ~/.local/standalone/Zotero_linux-x86_64/zotero ~/.local/bin/
ln -s ~/.local/standalone/Zotero_linux-x86_64/zotero.desktop ~/.local/share/applications/
popd

# install timeshift
sudo apt-get -y install timeshift

# snaps
sudo snap install code --classic
sudo snap install spotify gimp vlc universal-ctags

# vs code extensions
./vscode-install-extensions.sh

# install veracrypt
pushd $(mktemp -d)
sudo apt-get -y install libwxgtk3.0-gtk3-0v5 libayatana-appindicator3-1
sudo apt -y --fix-broken install
wget https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Debian-11-amd64.deb
sudo dpkg -i veracrypt-1.25.9-Debian-11-amd64.deb
popd

# install haskell
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_INSTALL_STACK=1
export BOOTSTRAP_HASKELL_INSTALL_HLS=1
# .zshrc already contains the relevant line
# export BOOTSTRAP_HASKELL_ADJUST_BASHRC=1;
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# install handbrake
pushd $(mktemp -d)
sudo apt -y install flatpak
sudo apt -y install gnome-software-plugin-flatpak
wget https://dl.flathub.org/repo/appstream/fr.handbrake.ghb.flatpakref
sudo flatpak install -y fr.handbrake.ghb.flatpakref
popd

# install gh (github cli)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y

# install unclutter
# NB: if the target system is using Wayland instead of X, the associated
# unclutter-startup is currently broken. I've filed a bug at
# https://bugs.launchpad.net/ubuntu/+source/unclutter/+bug/1998720
sudo apt-get -y install unclutter-xfixes
sudo perl -pi -e 's/(EXTRA_OPTS=).*/$1"--timeout 2"/' /etc/default/unclutter

# install delta
pushd $(mktemp -d)
wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.deb
popd

# install navi
cargo install --locked navi

# install lua + rocks
pushd $(mktemp -d)
curl -R -O http://www.lua.org/ftp/lua-5.4.6.tar.gz
tar zxf lua-5.4.6.tar.gz
cd lua-5.4.6
make all test
sudo make install
cd ..
curl -R -O http://luarocks.github.io/luarocks/releases/luarocks-3.9.2.tar.gz
tar zxf luarocks-3.9.2.tar.gz
cd luarocks-3.9.2
./configure --with-lua-include=/usr/local/include
make
sudo make install
popd
luarocks install croissant --local

# install HoDoKu. Note that this relies on java being available (default-jre is
# installed above)
mkdir -p ~/.local/jars/
wget -o ~/.local/jars/hodoku.jar https://netactuate.dl.sourceforge.net/project/hodoku/hodoku/hodoku_2.2.0/hodoku.jar
echo \[Desktop Entry\] >~/.local/share/applications/Hodoku.desktop
echo Name=Btop >>~/.local/share/applications/Hodoku.desktop
echo Exec=java -jar $HOME/.local/jars/hodoku.jar >>~/.local/share/applications/Hodoku.desktop
echo StartupNotify=true >>~/.local/share/applications/Hodoku.desktop
echo Terminal=true >>~/.local/share/applications/Hodoku.desktop
echo Type=Application >>~/.local/share/applications/Hodoku.desktop
# This probably isn't necessary in an installation situation, but it's useful
# when making changes as an admin
sudo update-desktop-database

# install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
# your system-wide PATH)
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
# Place the kitty.desktop file somewhere it can be found by the OS
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
# Update the paths to the kitty and its icon in the kitty desktop file(s)
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
# Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
echo 'kitty.desktop' >~/.config/xdg-terminals.list
# Create a symbolic link to the config file
ln -sf $PATH_TO_DOT_FILES/kitty.conf $HOME/.config/kitty/
# And also to the zoom_toggle kitten
ln -sf $PATH_TO_DOT_FILES/zoom_toggle.py $HOME/.config/kitty/
# make kitty the default terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
# install https://github.com/yurikhan/kitty_grab
pushd ~/.config/kitty
git clone https://github.com/yurikhan/kitty_grab.git
cp kitty_grab/grab-vim.conf.example grab.conf
sed -ri 's/# (map q\s*quit)/\1/' grab.conf
popd
# install a theme
ln -sf $PATH_TO_DOT_FILES/kitty.theme.conf $HOME/.config/kitty/

# install lazygit
pushd $(mktemp -d)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
popd

# install fd
sudo apt-get install -y fd-find
ln -sf $(which fdfind) ~/.local/bin/fd
