# zshell loads this file for all shells, including non-interactive. as such,
# it's particularly useful for aliases which we want to be able to use in a
# non-interactive shell e.g. inside vim

# Custom path locations. There are more of these in .zshrc, but they're grouped
# together with other program-specific stuff. This is convenient to load *most*
# of my expected path without doing anything else for scripting purposes
export PATH=~/.local/bin/:$PATH
export PATH=~/.yarn/bin:$PATH
export PATH=~/go/bin:$PATH
export PATH=/usr/local/go/bin:$PATH
export PATH="$HOME/.poetry/bin:$PATH"
export PATH=~/.luarocks/bin:$PATH
# This one is actually repeated in .zshrc, which is fine since it's guarded
FZF_PATH=$HOME/.local/share/nvim/lazy/fzf
if [[ ! "$PATH" == *$FZF_PATH/bin* ]]; then
  PATH="${PATH:+${PATH}:}$FZF_PATH/bin"
fi

alias clip="xclip -selection clipboard"
. "$HOME/.cargo/env"
