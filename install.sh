#!/usr/bin/env bash
# USAGE: ./install.sh [options]
#   --list              show every step, its profile and whether it has completed
#   --profile P         core | desktop | all. Default: all on a machine with a
#                       graphical session/target, core otherwise (e.g. servers,
#                       containers)
#   --only a,b          run just these steps, regardless of profile or state
#   --skip a,b          skip these steps
#   --with a,b          also run these optional steps (see below)
#   --force             re-run steps that already completed
#   --trace             run steps under set -x
#   -h, --help          show this help
#
# NOTES:
# - The script is a list of steps (see `--list`). Each runs in its own process
#   with output teed to a log, so one failure doesn't stop the rest: failures
#   are collected and summarized at the end, and a re-run only repeats steps
#   that haven't completed. Use --only to run a single step.
# - Steps are tagged `core` (CLI/dev tooling, fine for an ssh-only box) or
#   `desktop` (GNOME settings, GUI apps, hardware config).
# - Some steps are also `optional` (heavy, or rarely used, e.g. haskell). They
#   never run by default. At the start of a run in a terminal you're asked
#   about each one that hasn't completed yet; otherwise enable them with
#   --with (or --only).
# - The script will prompt for root priviledges once at the beginning. It is
#   otherwise unattended, with one exception: the claude_config step runs
#   `gh auth login --web` if gh isn't already logged in, and needs you to
#   complete the browser device flow before the private claude-config repo can
#   be cloned. Without a terminal (or GH_TOKEN) that step is deferred instead.
#   DO NOT RUN AS ROOT
# - After installation, nvim will need to be restarted to run correctly with
#   all plugins. use :checkhealth after restart to verify everything is happy
# - If it's been a while since this file was updated, any explicitly-specified
#   program versions should be checked and updated as needed (python, node, rg,
#   etc.)
# - Handbrake is not available until after a system restart
# TESTED ON: Ubuntu 24.04, 26.04

if [ "$(id -u)" -eq 0 ]; then
    echo This script should not be run as root.
    echo Please run it normally and priviledges will be escalated as needed
    exit 1
fi
set -Eeuo pipefail
# not set in e.g. containers
: "${USER:=$(id -un)}"
export USER

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
# we'll be creating softlinks in various locations to several files in the
# script directory. per e.g. https://stackoverflow.com/a/246128/12162258, this
# captures said directory
PATH_TO_DOT_FILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install"
LOG_FILE="$STATE_DIR/install.log"

# the python version will need to be updated in the future
PYTHON_LATEST=3.14.6

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# exit a step with the "deferred" status: not a failure, but not complete either
defer() {
    warn "$*"
    exit 75
}

# Ubuntu release, e.g. 24.04. Doesn't depend on lsb-release being installed
ubuntu_version() { (. /etc/os-release && echo "$VERSION_ID"); }
# only_on 24.04 26.04: succeeds if we're running one of the listed releases
only_on() {
    local v
    v="$(ubuntu_version)"
    local x
    for x in "$@"; do
        [ "$x" = "$v" ] && return 0
    done
    return 1
}

# PATH and friends for tools installed by earlier steps. Every step runs in a
# fresh process, so this is what stands in for "restart the shell". It's cheap
# and idempotent, and steps call it again after installing something
setup_env() {
    mkdir -p "$HOME/.local/bin"
    export PYENV_ROOT="$HOME/.pyenv"
    local d nodebin
    nodebin="$(ls -d "$HOME"/.nvm/versions/node/v*/bin 2>/dev/null | sort -V | tail -n1 || true)"
    # later entries end up earlier in PATH
    for d in /snap/bin /usr/local/go/bin "$HOME/.daml/bin" "$HOME/.ghcup/bin" \
        "$HOME/.cargo/bin" ${nodebin:+"$nodebin"} "$PYENV_ROOT/bin" "$PYENV_ROOT/shims" \
        "$HOME/.local/bin"; do
        case ":$PATH:" in
        *":$d:"*) ;;
        *) PATH="$d:$PATH" ;;
        esac
    done
    export PATH
    # so gsettings & co work from an ssh session on a machine with a desktop
    # session running
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "/run/user/$(id -u)/bus" ]; then
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
        export DBUS_SESSION_BUS_ADDRESS
    fi
    return 0
}

# for the rest of the script, it will be convenient to refer to pip concisely
# (note that aliases aren't expanded in scripts, but functions work fine)
pip() { python -m pip "$@"; }

apt_get() { sudo env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confold "$@"; }
# install packages as one transaction, falling back to one at a time so that a
# single package that doesn't exist on this release doesn't sink the rest
apt_install() {
    if apt_get install "$@"; then
        return 0
    fi
    local failed=() p
    for p in "$@"; do
        apt_get install "$p" || failed+=("$p")
    done
    if [ "${#failed[@]}" -gt 0 ]; then
        warn "could not install: ${failed[*]}"
        return 1
    fi
}

# link SRC DST: (re)create symlink DST -> SRC, creating DST's parent. Safe to
# repeat. Note that plain `ln -sf SRC DST` silently creates the link *inside*
# DST if that is an existing directory (or a symlink to one), which is why -n
# is used. A real directory in the way is moved aside rather than linked into
link() {
    local src=$1 dst=$2
    mkdir -p "$(dirname "$dst")"
    if [ -d "$dst" ] && [ ! -L "$dst" ]; then
        warn "$dst is a real directory; moving it to $dst.bak"
        mv "$dst" "$dst.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
}

# clone URL DIR [git args]: clone unless DIR is already there
clone() {
    local url=$1 dir=$2
    shift 2
    if [ -d "$dir/.git" ]; then
        echo "$dir already cloned"
    else
        mkdir -p "$(dirname "$dir")"
        git clone "$@" "$url" "$dir"
    fi
}

# gset SCHEMA KEY VALUE: gsettings set, but a schema or key that doesn't exist
# on this release/desktop is a warning instead of a fatal error
gset() {
    if ! have gsettings; then
        warn "gsettings not available, skipping $1 $2"
        return 0
    fi
    if ! gsettings range "$1" "$2" >/dev/null 2>&1; then
        warn "gsettings: $1 $2 doesn't exist here, skipping"
        return 0
    fi
    gsettings set "$1" "$2" "$3"
}

# ---------------------------------------------------------------------------
# step registry. `step NAME PROFILE "description" [flags...]` is followed by
# the function step_NAME. Steps run in the order they're registered here.
# Flags:
#   interactive  gets the terminal directly instead of being teed to the log
#   optional     only runs when asked for (prompt at start, --with or --only)
# ---------------------------------------------------------------------------

STEP_NAMES=()
declare -A STEP_PROFILE=() STEP_DESC=() STEP_FLAGS=()
step() {
    STEP_NAMES+=("$1")
    STEP_PROFILE[$1]=$2
    STEP_DESC[$1]=$3
    STEP_FLAGS[$1]=" ${*:4} "
}
step_has_flag() { [[ "${STEP_FLAGS[$1]}" == *" $2 "* ]]; }

# ---------------------------------------------------------------------------
# steps
# ---------------------------------------------------------------------------

# install/use display drivers (restart needed)
# UPDATE: no longer needed as of resolute
# sudo ubuntu-drivers autoinstall
# sudo prime-select nvidia

step apt_base core "system update and base apt packages"
step_apt_base() {
    # make everything up-to-date and clean
    apt_get update
    apt_get upgrade
    apt_get autoremove
    apt_get autoclean
    # one name changed in 24.04 with the 64-bit time_t transition. needed to run
    # AppImages (nvim)
    local fuse=libfuse2
    apt-cache show libfuse2t64 >/dev/null 2>&1 && fuse=libfuse2t64
    local pkgs=(
        # install curl, git, zsh...
        curl wget git zsh htop iftop gcc make
        jq tmux datamash nmap bvi httpie ripgrep
        tree perl-doc fortunes
        cowsay at ranger sshfs
        figlet whois default-jre moreutils dict lshw
        ssh shfmt translate-shell
        7zip bzip3 unzip xz-utils gpg "$fuse"
        clangd doxygen imagemagick pass fd-find btop
        # pyenv build environment, per
        # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
        build-essential libssl-dev zlib1g-dev
        libbz2-dev libreadline-dev libsqlite3-dev llvm
        libncursesw5-dev tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        # lazy.nvim builds rocks against Lua 5.1, which is what Neovim embeds,
        # so it needs lua5.1 in PATH alongside the lua built in the lua step
        lua5.1 liblua5.1-0-dev
        # ghcup/GHC
        libgmp-dev libncurses-dev
    )
    # kernel-specific perf tools. Not installable in a container
    [ -f /.dockerenv ] || pkgs+=(linux-tools-common linux-tools-generic)
    apt_install "${pkgs[@]}"
}

step apt_desktop desktop "GUI/desktop apt packages"
step_apt_desktop() {
    apt_install peek gnome-weather gnome-tweaks mkvtoolnix gnome-boxes \
        gnome-browser-connector mesa-utils mutter-dev-bin ydotool \
        xclip xsel timeshift
}

step dotfile_links core "git and ranger config links"
step_dotfile_links() {
    link "$PATH_TO_DOT_FILES/.gitconfig" "$HOME/.gitconfig"
    link "$PATH_TO_DOT_FILES/rc.conf" "$HOME/.config/ranger/rc.conf"
    link "$PATH_TO_DOT_FILES/ranger-scope.sh" "$HOME/.config/ranger/scope.sh"
}

step pyenv core "pyenv, python and python packages"
step_pyenv() {
    [ -d "$PYENV_ROOT" ] || curl -fsSL https://pyenv.run | bash
    setup_env
    pyenv install -s "$PYTHON_LATEST"
    # and make it the global version
    pyenv global "$PYTHON_LATEST"
    # make sure that pip is up-to-date
    pip install --upgrade pip
    # then install some useful packages
    pip install --user wheel
    pip install --user black tqdm jupytext csvkit ipython numpy matplotlib thefuck pipx nvitop
}

step ohmyzsh core "oh-my-zsh, zsh as default shell, and plugins"
step_ohmyzsh() {
    [ -d "$HOME/.oh-my-zsh" ] ||
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
    # copy config files
    link "$PATH_TO_DOT_FILES/.zshrc" "$HOME/.zshrc"
    link "$PATH_TO_DOT_FILES/.zshenv" "$HOME/.zshenv"
    # change zsh to default. the install script can do this too, but only
    # interactively.
    # UPDATE: type may specify that an executable is hashed, which screws up the
    # below (see https://askubuntu.com/a/446583/1014459 for what this means). which
    # will do no such thing, so it's more reliable for this particular bit of
    # automation
    # type zsh | awk '{print $3}' | xargs -I{} sudo chsh -s {} $USER
    which zsh | xargs -I{} sudo chsh -s {} "$USER"

    # install powerlevel10k config
    link "$PATH_TO_DOT_FILES/.p10k.zsh" "$HOME/.p10k.zsh"

    # install zsh-autosuggestions and rg
    clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    clone https://github.com/pressdarling/rg-zsh-plugin "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/rg"

    # install zplug. zplug is unacceptably slow to start on my machine. I may
    # reenable this in the future after an upgrade
    # curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
}

step tmux core ".tmux config"
step_tmux() {
    # it's a good idea to sync with gpakosz/.tmux before installing
    clone https://github.com/thisisrandy/.tmux.git "$HOME/.tmux"
    link "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    link "$HOME/.tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
}

step node core "nvm, node, corepack"
step_node() {
    # From https://nodejs.org/en/download:
    # Download and install nvm:
    [ -s "$HOME/.nvm/nvm.sh" ] ||
        curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # nvm refuses to work when npm has a prefix configured, which we do below.
    # remove it for the duration so that this step can be repeated
    if [ -f "$HOME/.npmrc" ]; then sed -i '/^prefix=/d' "$HOME/.npmrc"; fi
    # nvm isn't compatible with set -eu. Download and install Node.js:
    local rc=0
    trap - ERR
    set +eu
    . "$NVM_DIR/nvm.sh" && nvm install 24
    rc=$?
    set -eu
    trap err_trap ERR
    [ "$rc" -eq 0 ] || return "$rc"
    setup_env
    npm config set prefix ~/.local # prevents need to sudo for -g
    # per https://yarnpkg.com/getting-started/install, we should no longer install yarn directly
    npm install --global corepack
    # Since I use the oh-my-zsh nvm plugin to lazy-load and avoid costly shell
    # startup, I need to make a link to the real node location in a way that the
    # lsp understands. It's convenient to do it here in a bash context where
    # there's no ambiguity
    sudo ln -sf "$(command -v node)" /usr/local/bin/node
}

step clangd_config core "clangd user config"
step_clangd_config() {
    # clangd and doxygen themselves come from apt_base
    # I previously had this installing clangd-9, but I'm not sure why (jammy is at
    # v14, so v9 is pretty old). I'm leaving this here as a reminder that I might
    # have had a legitimate reason
    # sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100
    # user-level clangd config (enables Doxygen parsing in hovers)
    link "$PATH_TO_DOT_FILES/clangd-config.yaml" "$HOME/.config/clangd/config.yaml"
}

step fonts desktop "Nerd Font"
step_fonts() {
    # install powerline fonts that work with vscode. chosen from the selection at
    # https://www.nerdfonts.com/font-downloads
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/UbuntuMono.zip
    unzip -o UbuntuMono.zip
    mkdir -p ~/.local/share/fonts
    mv -f UbuntuMonoNerdFont-Regular.ttf ~/.local/share/fonts/
    sudo fc-cache -vf ~/.local/share/fonts/
}

step gnome_settings desktop "gnome-terminal profile and GNOME settings"
step_gnome_settings() {
    # the terminal needs to be set to use the font. per
    # https://ncona.com/2019/11/configuring-gnome-terminal-programmatically/, we
    # can do this programmatically. Note that if the font name of the install ttf
    # is unclear, we can run fc-list | less and search for the ttf file name
    local profile
    profile=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null |
        awk -F \' '{print $2}' || true)
    if [ -n "$profile" ]; then
        local t="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/"
        gset "$t" font 'UbuntuMono Nerd Font Regular 12'
        gset "$t" use-system-font false

        # gnome-terminal in jammy doesn't seem to fully support the system theme, so we
        # need to turn it off and select a scheme explicitly
        gset "$t" use-theme-colors false
        # this is the same as the tango dark built-in. it doesn't appear there's an
        # option to set a built-in via gsettings, but we can replicate its result
        # easily enough
        gset "$t" background-color "rgb(46,52,54)"
        gset "$t" foreground-color "rgb(211,215,207)"
        # this is solarized with the palette entry 8 changed to gray
        gset "$t" palette "['rgb(7,54,66)', 'rgb(220,50,47)', 'rgb(184,187,38)', 'rgb(181,137,0)', 'rgb(131,165,152)', 'rgb(211,54,130)', 'rgb(42,161,152)', 'rgb(238,232,213)', 'rgb(85,87,83)', 'rgb(203,75,22)', 'rgb(88,110,117)', 'rgb(101,123,131)', 'rgb(131,148,150)', 'rgb(108,113,196)', 'rgb(147,161,161)', 'rgb(253,246,227)']"

        # we can also take the opportunity to set a few other settings
        gset "$t" scrollbar-policy never
        gset "$t" audible-bell false
        gset "$t" use-theme-colors false
    else
        warn "no gnome-terminal profile found (the schema doesn't exist in resolute); skipping terminal settings"
    fi
    gset org.gnome.desktop.interface clock-format 12h
    # this screws with multiple vim plugins (breaks <C-...> mappings) so best to
    # leave it off
    gset org.gnome.desktop.interface locate-pointer false
    gset org.gnome.desktop.interface clock-show-weekday true
    gset org.gnome.desktop.interface clock-show-seconds true
    gset org.gnome.mutter workspaces-only-on-primary false
    # org.gnome.shell.extensions.desktop-icons is gone in resolute; gset skips it
    gset org.gnome.shell.extensions.desktop-icons show-trash false
    gset org.gnome.shell.extensions.desktop-icons show-home false
    gset org.gnome.settings-daemon.plugins.color night-light-enabled true
    gset org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
    gset org.gnome.settings-daemon.plugins.color night-light-temperature 4700 # the least warm possible
    # The tiling feature where it alters the alt+tab stack is super-annoying, to
    # disable it, we first ensure that the two menu items "Tiling Popup" and "Tile
    # Groups" are enabled and then file tune with a hidden setting that just
    # disables the drag whole group to front functionality
    gset org.gnome.shell.extensions.tiling-assistant enable-tiling-popup true
    gset org.gnome.shell.extensions.tiling-assistant disable-tile-groups false
    gset org.gnome.shell.extensions.tiling-assistant enable-raise-tile-group false
}

step rust core "rustup and cargo-binstall"
step_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # The rust installer wants us to restart the shell at this point. setup_env
    # takes care of adding the cargo path to PATH instead
    setup_env
    # Also install https://github.com/cargo-bins/cargo-binstall
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
}

step bat core "bat and bat-extras"
step_bat() {
    # install bat. per https://askubuntu.com/a/1300824/1014459, on 20.04 this needs
    # some special magic
    # sudo apt-get -y install -o Dpkg::Options::="--force-overwrite" bat
    # the version of bat that apt uses for 20.04 throws an error when opening files
    # inside a git repo. see
    # https://github.com/sharkdp/bat/issues/2317#issuecomment-1248343739. we can
    # just manually install the latest version instead
    wget https://github.com/sharkdp/bat/releases/download/v0.26.1/bat_0.26.1_amd64.deb
    sudo dpkg -i bat_0.26.1_amd64.deb
    # per https://github.com/sharkdp/bat#on-ubuntu-using-apt, bat might be installed
    # as batcat. set up a symlink so fzf can use it as bat
    have bat || ln -sf /usr/bin/batcat ~/.local/bin/bat
    # and extras
    curl -fLO https://github.com/eth-p/bat-extras/archive/master.zip
    unzip master.zip
    (cd bat-extras-master && sudo env "PATH=$PATH" ./build.sh --install)
    # the temp dir is cleaned up at the end of the step. build creates some
    # protected files, which is handled there
}

step daml core "daml"
step_daml() {
    curl -sSL https://get.daml.com/ | sh
}

step nvim core "neovim (stable and nightly) and its config"
step_nvim() {
    local bin="$HOME/.local/bin"
    curl -fLo "$bin/nvim" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod u+x "$bin/nvim"
    ln -sf nvim "$bin/vim"
    # NOTE: nightly is needed for all treesitter features to work properly
    curl -fLo "$bin/nvim.nightly" https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage
    chmod u+x "$bin/nvim.nightly"
    # My old setup for reference
    # mkdir -p $HOME/.config/nvim
    # ln -sf $PATH_TO_DOT_FILES/init.vim $HOME/.config/nvim/init.vim
    # ln -sf $PATH_TO_DOT_FILES/noplug.init.vim $HOME/.config/nvim/noplug.init.vim
    # ln -sf $PATH_TO_DOT_FILES/ts.init.vim $HOME/.config/nvim/ts.init.vim
    # ln -sf $PATH_TO_DOT_FILES/coc-settings.json $HOME/.config/nvim/coc-settings.json
    # LazyNvim setup
    link "$PATH_TO_DOT_FILES/lazy-nvim-config" "$HOME/.config/nvim"
}

step nvim_deps core "tools and language hosts that nvim plugins need"
step_nvim_deps() {
    # Some tools needed for Snacks.image as reported in the nvim healthcheck.
    # More image formats (imagemagick) come from apt_base
    # tectonic for LaTeX
    if ! have tectonic; then
        curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
        mv -f tectonic "$HOME/.local/bin"
    fi
    # mermaid
    npm install -g @mermaid-js/mermaid-cli
    # nvim-treesitter requirement
    cargo binstall -y tree-sitter-cli
    # Some other setup for nvim itself. (yarn global was removed in yarn 2+)
    npm install -g neovim
    # create a virtual env specifically for nvim and install the relevant packages
    # in it. init.vim must specify g:python3_host_prog pointing to bin/python in
    # the vevn
    pyenv virtualenvs --bare | grep -qx neovim || pyenv virtualenv "$PYTHON_LATEST" neovim
    "$(pyenv prefix neovim)/bin/python" -m pip install wheel neovim
}

step vscode desktop "VS Code from Microsoft's apt repository"
step_vscode() {
    # the snap has been problematic, so use the .deb via Microsoft's apt repo,
    # per https://code.visualstudio.com/docs/setup/linux
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
    sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
    printf '%s\n' 'Types: deb' 'URIs: https://packages.microsoft.com/repos/code' \
        'Suites: stable' 'Components: main' 'Architectures: amd64,arm64,armhf' \
        'Signed-By: /usr/share/keyrings/microsoft.gpg' |
        sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null
    apt_get update
    apt_install code
}

step vscode_settings desktop "VS Code settings links"
step_vscode_settings() {
    link "$PATH_TO_DOT_FILES/vscode-settings.json" "$HOME/.config/Code/User/settings.json"
    link "$PATH_TO_DOT_FILES/vscode-keybindings.json" "$HOME/.config/Code/User/keybindings.json"
}

# install docker
# FIXME: This is broken in resolute, if not earlier. Specifically, docker-ce and
# friends don't exist anymore
# sudo apt-get -y install \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg-agent \
#     software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository -y \
#     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# give current user permission to run docker (requires restart)
# sudo usermod -aG docker $USER

step poetry core "poetry"
step_poetry() {
    curl -sSL https://install.python-poetry.org/ | python -
    poetry config virtualenvs.in-project true
}

step zsh_extras core "oh-my-zsh context extras (poetry completions, p10k, syntax highlighting)"
step_zsh_extras() {
    # run zsh-install.sh for any additional steps in the oh-my-zsh context. It
    # runs after poetry so the completions can be generated
    "$PATH_TO_DOT_FILES/zsh-install.sh"
}

step inotify core "raise inotify watch limit"
step_inotify() {
    # increase default number of file watchers (for webpack, see
    # https://github.com/webpack/docs/wiki/troubleshooting#not-enough-watchers)
    echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
    # this can't be changed from inside a container
    sudo sysctl -p /etc/sysctl.d/99-inotify.conf || warn "couldn't apply sysctl now; it will apply on next boot"
}

step btop core "btop config"
step_btop() {
    # btop itself comes from apt_base. It used to be built from source (which
    # needed gcc-11, no longer available), and its desktop entry used to be
    # created by hand. Neither is needed any more
    # echo \[Desktop Entry\] > ~/.local/share/applications/Btop.desktop
    # echo Name=Btop >> ~/.local/share/applications/Btop.desktop
    # echo Exec=/usr/local/bin/btop >> ~/.local/share/applications/Btop.desktop
    # echo StartupNotify=true >> ~/.local/share/applications/Btop.desktop
    # echo Terminal=true >> ~/.local/share/applications/Btop.desktop
    # echo Type=Application >> ~/.local/share/applications/Btop.desktop
    # install the config file
    link "$PATH_TO_DOT_FILES/btop.conf" "$HOME/.config/btop/btop.conf"
}

step grub desktop "show the full boot sequence"
step_grub() {
    # make sure grub shows the full startup sequence
    sudo sed -i 's/quiet splash//' /etc/default/grub
    sudo update-grub
}

step zotero desktop "zotero"
step_zotero() {
    [ ! -d ~/.local/standalone/Zotero_linux-x86_64 ] || {
        echo "zotero already installed"
        return 0
    }
    wget 'https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64' -O zotero.tar.xz
    tar xf zotero.tar.xz
    wget https://www.zotero.org/support/_media/logo/zotero_128x128x32.png
    mv zotero_128x128x32.png Zotero_linux-x86_64/
    sed -i 's@zotero\.ico@'"$HOME"'/.local/standalone/Zotero_linux-x86_64/zotero_128x128x32.png@' \
        Zotero_linux-x86_64/zotero.desktop
    mkdir -p ~/.local/standalone
    mv Zotero_linux-x86_64 ~/.local/standalone/
    ln -sf ~/.local/standalone/Zotero_linux-x86_64/zotero ~/.local/bin/
    mkdir -p ~/.local/share/applications
    ln -sf ~/.local/standalone/Zotero_linux-x86_64/zotero.desktop ~/.local/share/applications/
}

step snaps desktop "snap apps (spotify, gimp, vlc, ctags)"
step_snaps() {
    sudo snap install spotify gimp vlc universal-ctags
}

step vscode_extensions desktop "VS Code extensions"
step_vscode_extensions() {
    "$PATH_TO_DOT_FILES/vscode-install-extensions.sh"
}

step veracrypt desktop "veracrypt"
step_veracrypt() {
    apt_install libwxgtk3.2-1t64 libayatana-appindicator3-1
    apt_get --fix-broken install
    # the release publishes a build per Ubuntu version
    local deb
    deb="veracrypt-1.26.29-Ubuntu-$(ubuntu_version)-amd64.deb"
    wget "https://launchpad.net/veracrypt/trunk/1.26.29/+download/$deb"
    sudo dpkg -i "$deb"
}

step haskell core "ghcup, stack, HLS (large download)" optional
step_haskell() {
    export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
    export BOOTSTRAP_HASKELL_INSTALL_STACK=1
    export BOOTSTRAP_HASKELL_INSTALL_HLS=1
    # .zshrc already contains the relevant line
    # export BOOTSTRAP_HASKELL_ADJUST_BASHRC=1;
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
}

step flatpak desktop "flatpak, HandBrake and D-Spy"
step_flatpak() {
    apt_install flatpak gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    # install handbrake
    wget https://dl.flathub.org/repo/appstream/fr.handbrake.ghb.flatpakref
    sudo flatpak install -y fr.handbrake.ghb.flatpakref
    # install D-Spy
    flatpak install -y flathub org.gnome.dspy
}

step gh core "gh (github cli)"
step_gh() {
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -nv -O keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg <keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    sudo mkdir -p -m 755 /etc/apt/sources.list.d
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    apt_get update
    apt_install gh
}

step claude_config core "private Claude Code global config (needs gh login)" interactive
step_claude_config() {
    # check out my private Claude Code global config and link it into ~/.claude.
    # The repo is private, so cloning needs credentials. gh was just installed,
    # so use it: log in via the browser device flow if we aren't already (the one
    # interactive step), register gh as git's credential helper for github.com,
    # and clone with it
    have gh || return 1
    if ! gh auth status >/dev/null 2>&1; then
        if [ -t 0 ]; then
            gh auth login --hostname github.com --git-protocol https --web
        else
            defer "gh isn't logged in and there's no terminal. Set GH_TOKEN or run ./install.sh --only claude_config from a terminal"
        fi
    fi
    gh auth setup-git
    [ -d ~/git/claude-config ] || gh repo clone thisisrandy/claude-config ~/git/claude-config
    link ~/git/claude-config/CLAUDE.md "$HOME/.claude/CLAUDE.md"
    link ~/git/claude-config/settings.json "$HOME/.claude/settings.json"
}

step unclutter desktop "unclutter (hide idle mouse pointer)"
step_unclutter() {
    # NB: if the target system is using Wayland instead of X, the associated
    # unclutter-startup is currently broken. I've filed a bug at
    # https://bugs.launchpad.net/ubuntu/+source/unclutter/+bug/1998720
    apt_install unclutter-xfixes
    sudo perl -pi -e 's/(EXTRA_OPTS=).*/$1"--timeout 2"/' /etc/default/unclutter
}

step delta core "delta"
step_delta() {
    wget https://github.com/dandavison/delta/releases/download/0.20.1/git-delta_0.20.1_amd64.deb
    sudo dpkg -i git-delta_0.20.1_amd64.deb
}

step navi core "navi"
step_navi() {
    cargo install --locked navi
}

step lua core "lua and luarocks"
step_lua() {
    curl -fL -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz
    tar zxf lua-5.5.0.tar.gz
    (cd lua-5.5.0 && make all test && sudo make install)
    # lua5.1 (apt_base) must also be in PATH, see there. That makes it
    # luarocks' preferred interpreter, so point configure at the lua just built
    curl -fR -O https://luarocks.github.io/luarocks/releases/luarocks-3.13.0.tar.gz
    tar zxf luarocks-3.13.0.tar.gz
    (cd luarocks-3.13.0 && ./configure --with-lua=/usr/local && make && sudo make install)
    # This isn't available on lua 5.5. lua -i can be used as an alternative
    # luarocks install croissant --local
}

# install HoDoKu. Note that this relies on java being available (default-jre is
# installed above)
# FIXME: The jar reads as corrupt on resolute/jre(v?)
# mkdir -p ~/.local/jars/
# wget -o ~/.local/jars/hodoku.jar https://netactuate.dl.sourceforge.net/project/hodoku/hodoku/hodoku_2.2.0/hodoku.jar
# echo \[Desktop Entry\] >~/.local/share/applications/Hodoku.desktop
# echo Name=HoDoKu >>~/.local/share/applications/Hodoku.desktop
# echo Exec=java -jar $HOME/.local/jars/hodoku.jar >>~/.local/share/applications/Hodoku.desktop
# echo StartupNotify=true >>~/.local/share/applications/Hodoku.desktop
# echo Terminal=true >>~/.local/share/applications/Hodoku.desktop
# echo Type=Application >>~/.local/share/applications/Hodoku.desktop
# This probably isn't necessary in an installation situation, but it's useful
# when making changes as an admin
# sudo update-desktop-database

step kitty desktop "kitty, its config, kitty_grab and theme"
step_kitty() {
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    # Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
    # your system-wide PATH)
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
    # Place the kitty.desktop file somewhere it can be found by the OS
    mkdir -p ~/.local/share/applications
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
    # Update the paths to the kitty and its icon in the kitty desktop file(s)
    sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
    # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
    echo 'kitty.desktop' >~/.config/ubuntu-xdg-terminals.list
    # The last time I installed kitty, it didn't create its directory under
    # .config, so ensure it's there. Then link the config file, the zoom_toggle
    # kitten, a tab picker script and the theme
    link "$PATH_TO_DOT_FILES/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    link "$PATH_TO_DOT_FILES/zoom_toggle.py" "$HOME/.config/kitty/zoom_toggle.py"
    link "$PATH_TO_DOT_FILES/kitty-tab-picker.sh" "$HOME/.config/kitty/kitty-tab-picker.sh"
    link "$PATH_TO_DOT_FILES/kitty.theme.conf" "$HOME/.config/kitty/kitty.theme.conf"
    # make kitty the default terminal
    # The gsetting is what Ctrl+Alt+T uses on 24.04. It's outdated and doesn't work
    # on resolute (26.04), where ubuntu-xdg-terminals.list above does the job and
    # leaving the gsetting at its default is fine
    if only_on 24.04; then
        gset org.gnome.desktop.default-applications.terminal exec 'kitty'
    fi
    # install https://github.com/yurikhan/kitty_grab
    if [ ! -d ~/.config/kitty/kitty_grab ]; then
        git clone https://github.com/yurikhan/kitty_grab.git ~/.config/kitty/kitty_grab
        cp ~/.config/kitty/kitty_grab/grab-vim.conf.example ~/.config/kitty/grab.conf
        sed -ri 's/# (map q\s*quit)/\1/' ~/.config/kitty/grab.conf
    fi
}

step lazygit core "lazygit"
step_lazygit() {
    local version
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -fLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    link "$PATH_TO_DOT_FILES/lazygit-config.yml" "$HOME/.config/lazygit/config.yml"
}

step fd core "fd link (package comes from apt_base)"
step_fd() {
    link "$(command -v fdfind)" "$HOME/.local/bin/fd"
}

step iriun desktop "iriun webcam"
step_iriun() {
    wget https://iriun.gitlab.io/iriunwebcam-2.9.1.deb
    sudo dpkg -i iriunwebcam-2.9.1.deb
    apt_install libqt5widgets5 v4l2loopback-dkms
    apt_get --fix-broken install
}

step antigravity core "Antigravity CLI"
step_antigravity() {
    curl -fsSL https://antigravity.google/cli/install.sh | bash
}

step copilot core "Copilot CLI"
step_copilot() {
    curl -fsSL https://gh.io/copilot-install | bash
}

step gdctl desktop "gdctl dependencies and laptop monitor toggle"
step_gdctl() {
    # install gdctl dependencies along with my laptop monitor toggle script
    apt_install libcairo2-dev libxt-dev libgirepository-2.0-dev
    pip install pycairo PyGObject
    link "$PATH_TO_DOT_FILES/laptop-monitor-toggle" "$HOME/.local/bin/laptop-monitor-toggle"
    # this is general purpose, but I wrote it for this and only use it here
    link "$PATH_TO_DOT_FILES/set-custom-shortcut" "$HOME/.local/bin/set-custom-shortcut"
    # it appends a new shortcut every time it runs, so this step must only run once
    perl -E 'say "Toggle Movie Mode"; say "$ENV{HOME}/.local/bin/laptop-monitor-toggle"; say "<Super>bracketright"' | set-custom-shortcut
}

step go core "go"
step_go() {
    wget https://go.dev/dl/go1.26.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.26.5.linux-amd64.tar.gz
}

step crush core "crush and its config"
step_crush() {
    # install crush. See https://github.com/charmbracelet for the full charm
    # ecosystem. Can also be installed directly as a go app (see docs)
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    apt_get update
    apt_install crush
    # install its config file, too. I'm relying on mason to manage LSPs. I
    # basically asked crush to analyze the mason packages dir and autogenerate this
    link "$PATH_TO_DOT_FILES/crush.json" "$HOME/.local/share/crush/crush.json"
}

step opencode core "OpenCode"
step_opencode() {
    curl -fsSL https://opencode.ai/install | bash
}

step arm_toolchain core "Arm GNU EABI toolchain"
step_arm_toolchain() {
    # install Arm GNU EABI (Embedded Application Binary Interface) toolchain. See
    # https://gitlab.arm.com/tooling/gnu-toolchains-for-arm/-/tree/releases/15.3.rel1
    local f=arm-gnu-toolchain-15.3.rel1-x86_64-arm-none-eabi.tar.xz
    wget "https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/15.3.rel1/$f"
    mkdir -p ~/.local/share
    tar xJf "$f" -C ~/.local/share
}

step todoist desktop "Todoist"
step_todoist() {
    sudo snap install todoist
    sudo snap set core experimental.refresh-app-awareness=true
}

step clockify desktop "Clockify"
step_clockify() {
    wget https://clockify.me/downloads/Clockify_Setup_x64.deb
    sudo dpkg -i Clockify_Setup_x64.deb
}

step markdownlint core "markdownlint-cli2"
step_markdownlint() {
    npm install markdownlint-cli2 --global
}

# ---------------------------------------------------------------------------
# runner
# ---------------------------------------------------------------------------

usage() { sed -n '2,/^# TESTED ON/{s/^# \{0,1\}//;p}' "$SELF" | sed '$d'; }

in_list() {
    local needle=$1 x
    shift
    for x in "$@"; do
        [ "$x" = "$needle" ] && return 0
    done
    return 1
}

default_profile() {
    if [ -n "${XDG_CURRENT_DESKTOP:-}${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] ||
        [ "$(systemctl get-default 2>/dev/null || true)" = graphical.target ]; then
        echo all
    else
        echo core
    fi
}

err_trap() { echo "!! step $CURRENT_STEP failed at line ${BASH_LINENO[0]}: $BASH_COMMAND" >&2; }

# ask about each optional step that is in scope and hasn't been handled. The
# answers accumulate in WITH, which lives in this (the parent) process for the
# rest of the run. Steps run in child processes, but they don't need to know
ask_optional() {
    local name ans
    for name in "${STEP_NAMES[@]}"; do
        step_has_flag "$name" optional || continue
        [ "$PROFILE" = all ] || [ "$PROFILE" = "${STEP_PROFILE[$name]}" ] || continue
        in_list "$name" "${WITH[@]}" && continue
        in_list "$name" "${SKIP[@]}" && continue
        [ -z "$FORCE" ] && [ -e "$STATE_DIR/done/$name" ] && continue
        if [ -t 0 ] && [ -t 1 ]; then
            read -r -p "Install optional step '$name' (${STEP_DESC[$name]})? [y/N] " ans || ans=
            case $ans in [yY]*) WITH+=("$name") ;; esac
        fi
    done
}

# runs one step in this process. Called via re-exec by the runner, so that
# set -e is in full effect inside the step (it's ignored inside anything that is
# the condition of an if, or the left side of ||)
run_internal() {
    local name=$1
    setup_env
    CURRENT_STEP=$name
    WORKDIR="$(mktemp -d)"
    # build steps can leave protected files behind
    trap 'cd /; rm -rf "$WORKDIR" 2>/dev/null || sudo rm -rf "$WORKDIR"' EXIT
    trap err_trap ERR
    cd "$WORKDIR"
    if [ -n "${INSTALL_TRACE:-}" ]; then set -x; fi
    "step_$name"
}

run_steps() {
    local name rc
    local done_steps=() already=() failed=() deferred=() not_selected=()
    mkdir -p "$STATE_DIR/done"
    for name in "${STEP_NAMES[@]}"; do
        if [ "${#ONLY[@]}" -gt 0 ]; then
            in_list "$name" "${ONLY[@]}" || continue
        else
            if [ "${#SKIP[@]}" -gt 0 ] && in_list "$name" "${SKIP[@]}"; then continue; fi
            if [ "$PROFILE" != all ] && [ "$PROFILE" != "${STEP_PROFILE[$name]}" ]; then continue; fi
            if step_has_flag "$name" optional && ! in_list "$name" "${WITH[@]}"; then
                not_selected+=("$name")
                continue
            fi
            if [ -e "$STATE_DIR/done/$name" ] && [ -z "$FORCE" ]; then
                already+=("$name")
                continue
            fi
        fi
        log "[$name] ${STEP_DESC[$name]}"
        echo "=== $(date '+%F %T') [$name] start" >>"$LOG_FILE"
        set +e
        if step_has_flag "$name" interactive; then
            bash "$SELF" --internal-run "$name"
            rc=$?
        else
            bash "$SELF" --internal-run "$name" 2>&1 | tee -a "$LOG_FILE"
            rc=${PIPESTATUS[0]}
        fi
        set -e
        echo "=== $(date '+%F %T') [$name] exit $rc" >>"$LOG_FILE"
        case $rc in
        0)
            touch "$STATE_DIR/done/$name"
            done_steps+=("$name")
            ;;
        75) deferred+=("$name") ;;
        *) failed+=("$name") ;;
        esac
    done

    printf '\n==================== summary ====================\n'
    printf 'completed:        %s\n' "${done_steps[*]:-none}"
    printf 'already done:     %s\n' "${already[*]:-none}"
    printf 'deferred:         %s\n' "${deferred[*]:-none}"
    [ "${#not_selected[@]}" -eq 0 ] ||
        printf 'optional, not run: %s (use --with)\n' "${not_selected[*]}"
    printf 'FAILED:           %s\n' "${failed[*]:-none}"
    printf 'log:              %s\n' "$LOG_FILE"
    if [ "${#failed[@]}" -gt 0 ]; then
        printf 'Retry with:       %s --only %s\n' "$0" "$(
            IFS=,
            echo "${failed[*]}"
        )"
        return 1
    fi
}

list_steps() {
    local name status
    printf '%-18s %-8s %-6s %s\n' STEP PROFILE DONE DESCRIPTION
    for name in "${STEP_NAMES[@]}"; do
        status=no
        [ -e "$STATE_DIR/done/$name" ] && status=yes
        printf '%-18s %-8s %-6s %s%s\n' "$name" "${STEP_PROFILE[$name]}" "$status" "${STEP_DESC[$name]}" \
            "$(step_has_flag "$name" optional && echo ' [optional]')"
    done
}

main() {
    if [ "${1:-}" = --internal-run ]; then
        run_internal "$2"
        return
    fi

    PROFILE=
    FORCE=
    LIST=
    ONLY=()
    SKIP=()
    WITH=()
    while [ $# -gt 0 ]; do
        case $1 in
        --profile)
            PROFILE=${2:?--profile needs core, desktop or all}
            shift
            ;;
        --only)
            IFS=, read -ra ONLY <<<"${2:?--only needs a comma-separated list}"
            shift
            ;;
        --skip)
            IFS=, read -ra SKIP <<<"${2:?--skip needs a comma-separated list}"
            shift
            ;;
        --with)
            IFS=, read -ra WITH <<<"${2:?--with needs a comma-separated list}"
            shift
            ;;
        --force) FORCE=1 ;;
        --list) LIST=1 ;;
        --trace) export INSTALL_TRACE=1 ;;
        -h | --help)
            usage
            return 0
            ;;
        *)
            echo "unknown option: $1" >&2
            usage >&2
            return 2
            ;;
        esac
        shift
    done
    [ -n "$PROFILE" ] || PROFILE="$(default_profile)"
    case $PROFILE in core | desktop | all) ;; *)
        echo "unknown profile: $PROFILE" >&2
        return 2
        ;;
    esac
    local n
    for n in "${ONLY[@]}" "${SKIP[@]}" "${WITH[@]}"; do
        in_list "$n" "${STEP_NAMES[@]}" || {
            echo "unknown step: $n (see --list)" >&2
            return 2
        }
    done

    if [ -n "$LIST" ]; then
        list_steps
        return 0
    fi

    mkdir -p "$STATE_DIR"
    setup_env
    echo "profile: $PROFILE; log: $LOG_FILE"
    # questions first, so the rest of the run can be left unattended
    if [ "${#ONLY[@]}" -eq 0 ]; then ask_optional; fi
    # prompt for the sudo password once up front and keep the timestamp fresh
    # for the (potentially long) duration
    sudo -v
    (while kill -0 $$ 2>/dev/null; do
        sudo -n true
        sleep 50
    done) 2>/dev/null &
    trap 'kill $! 2>/dev/null || true' EXIT
    run_steps
}

main "$@"
