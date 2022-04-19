# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
# Install at https://ohmyz.sh/
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="avit"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git virtualenv zsh-autosuggestions poetry)
export ZSH_THEME_VIRTUALENV_PREFIX="("
export ZSH_THEME_VIRTUALENV_SUFFIX=")"

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

DEFAULT_USER='randy'
prompt_context(){}

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Custom path locations
export PATH=~/.local/bin/:$PATH
export PATH=~/.yarn/bin:$PATH
export PATH=~/go/bin:$PATH
export PATH=/usr/local/go/bin:$PATH
export PATH=/usr/local/go/bin:$PATH

# DAML
export PATH=~/.daml/bin:$PATH
fpath=(~/.daml/zsh $fpath)

# for TensorFlow. moot if TensorFlow not installed. see
# https://www.tensorflow.org/install/gpu
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64

# fzf
export FZF_DEFAULT_COMMAND='rg --files --glob !.git --hidden --follow'

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# history
export HISTSIZE=1000000
setopt HIST_IGNORE_ALL_DUPS
# all commands prefixed with a space will not be saved in history
setopt HIST_IGNORE_SPACE

# enable and customize vi-style key bindings in .tmux
export EDITOR=vim

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias sudoenv='sudo env "PATH=$PATH" "HOME=$HOME"'
alias p=pushd
alias po=popd
alias open='xdg-open'
alias start='nautilus --browser'
alias vnp='vim -u ~/.config/nvim/noplug.init.vim'
alias f="fzf --preview '[[ \$(file --mime {}) =~ binary ]] && \
                 echo {} is a binary file || \
                 bat --style=numbers --color=always {} | \
                 head -100'"
alias vf='vim "$(f)"'
alias lf='less "$(f)"'
alias python=python3
alias pip=pip3
alias venv="source .venv/bin/activate"
alias mr="pip freeze | grep -v pkg-resources > requirements.txt"
alias ip='ip -c'

# vi mode

bindkey -v

bindkey jk vi-cmd-mode

# All of this wipes out the rhs of the status line, which actually contains
# useful information. It also changes text to bold on exit to normal mode,
# weirdly even when the fonts are set to normal weight. Keeping commented here
# in case I want to revisit it at some point, but for now, I think it's easy
# enough to remember which mode I'm in
#
# vim_ins_mode="%{$fg_bold[cyan]%}[INSERT]%{$reset_color%}"
# vim_norm_mode="%{$fg_bold[yellow]%}[NORMAL]%{$reset_color%}"
# vim_mode=$vim_ins_mode
#
# function zle-keymap-select {
#   vim_mode="${${KEYMAP/vicmd/${vim_norm_mode}}/(main|viins)/${vim_ins_mode}}"
#   zle reset-prompt
# }
# zle -N zle-keymap-select
#
# function zle-line-finish {
#   vim_mode=$vim_ins_mode
# }
# zle -N zle-line-finish
#
# # Fix a bug when you C-c in CMD mode and you'd be prompted with CMD mode
# # indicator, while in fact you would be in INS mode Fixed by catching SIGINT
# # (C-c), set vim_mode to INS and then repropagate the SIGINT, so if anything
# # else depends on it, we will not break it
# function TRAPINT() {
#   vim_mode=$vim_ins_mode
#   return $(( 128 + $1 ))
# }
# RPROMPT='${vim_mode}'

# Wrap the zsh vi widgets to feed from/into xclip
# https://unix.stackexchange.com/questions/25765/pasting-from-clipboard-to-vi-enabled-zsh-or-bash-shell
function x11-clip-wrap-widgets() {
    # NB: Assume we are the first wrapper and that we only wrap native widgets
    # See zsh-autosuggestions.zsh for a more generic and more robust wrapper
    local copy_or_paste=$1
    shift

    for widget in $@; do
        # Ugh, zsh doesn't have closures
        if [[ $copy_or_paste == "copy" ]]; then
            eval "
            function _x11-clip-wrapped-$widget() {
                zle .$widget
                xclip -in -selection clipboard <<<\$CUTBUFFER
            }
            "
        else
            eval "
            function _x11-clip-wrapped-$widget() {
                CUTBUFFER=\$(xclip -out -selection clipboard)
                zle .$widget
            }
            "
        fi

        zle -N $widget _x11-clip-wrapped-$widget
    done
}


local copy_widgets=(
    vi-yank vi-yank-eol vi-delete vi-backward-kill-word vi-change-whole-line
)
local paste_widgets=(
    vi-put-{before,after}
)

# NB: can atm. only wrap native widgets
x11-clip-wrap-widgets copy $copy_widgets
x11-clip-wrap-widgets paste  $paste_widgets

# jog
function zshaddhistory() {
	echo "${1%%$'\n'}|${PWD}   " >> ~/.zsh_history_ext
}

# fzf setup. vi mode wipes out the fzf bindings, so make sure to put this
# after vi mode setup. note that fzf bindings only work in insert mode

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# start tmux if conditions met. see
# https://unix.stackexchange.com/a/113768/460319 and
# https://stackoverflow.com/a/69579460/12162258
if command -v tmux &> /dev/null \
   && [ -n "$PS1" ] \
   && [[ ! "$TERM" =~ screen ]] \
   && [[ ! "$TERM" =~ tmux ]] \
   && [ -z "$TMUX" ] \
   && ! pstree -s $$ | grep -Ewq "code|n?vim"; then
    if [[ -n $(pgrep tmux) ]]; then
        exec tmux attach
    else
        exec tmux new -s default
    fi
fi
