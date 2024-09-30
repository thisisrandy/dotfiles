# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
# Install at https://ohmyz.sh/
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
plugins=(git virtualenv zsh-autosuggestions poetry rust safe-paste ripgrep jump \
  jsontools emoji aliases zsh-syntax-highlighting)
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
export PATH="$HOME/.poetry/bin:$PATH"
export PATH=~/.luarocks/bin:$PATH

# DAML
export PATH=~/.daml/bin:$PATH
fpath=(~/.daml/zsh $fpath)

# for TensorFlow. moot if TensorFlow not installed. see
# https://www.tensorflow.org/install/gpu
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64

# fzf
export FZF_DEFAULT_COMMAND='rg --files --glob !.git --hidden --follow'
# This is Gruvbox Dark. See
# https://github.com/junegunn/fzf/wiki/Color-schemes#gruvbox-dark
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54'

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# thefuck
eval $(thefuck --alias)

# history
export HISTSIZE=1000000
setopt HIST_IGNORE_ALL_DUPS
# all commands prefixed with a space will not be saved in history
setopt HIST_IGNORE_SPACE

# enable and customize vi-style key bindings in .tmux
export EDITOR=vim
# we also need to turn down the key repeat delay to enable interactive split
# resizing
xset r rate 200 40


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
# this is better accomplished via `open .`
# alias start='nautilus --browser'
alias vnp='vim -u ~/.config/nvim/noplug.init.vim'
alias vts='nvim.nightly -u ~/.config/nvim/ts.init.vim'
alias f="fzf --preview '[[ \$(file --mime {}) =~ binary ]] && \
                 echo {} is a binary file || \
                 bat --style=numbers --color=always {} | \
                 head -100'"
alias r=ranger
alias v=vim
alias vd='COC_USE_DICT=true v'
alias vf='v "$(f)"'
alias vdf='COC_USE_DICT=true vf'
alias sv='sudoenv vim'
alias lf='less "$(f)"'
alias pip='python -m pip'
alias venv="source .venv/bin/activate"
alias mr="pip freeze | grep -v pkg-resources > requirements.txt"
alias ip='ip -c'
alias rg='rg --smart-case'
# swap zsh l and la (I prefer ls -lAh as my min keystroke alias)
alias l='ls -lAh'
alias la='ls -lah'
alias l1='ls -A1'
alias l1a='ls -a1'
# shortcuts for the jump plugin
alias j=jump
alias m=mark
alias um=unmark
alias ms=marks
# Shamelessly copied from https://superuser.com/a/1503113/1264067
# SP  ' '  0x20 = · U+00B7 Middle Dot
# TAB '\t' 0x09 = ￫ U+FFEB Halfwidth Rightwards Arrow
# CR  '\r' 0x0D = § U+00A7 Section Sign (⏎ U+23CE also works fine)
# LF  '\n' 0x0A = ¶ U+00B6 Pilcrow Sign (was "Paragraph Sign")
alias whitespace="sed 's/ /·/g;s/\t/￫/g;s/\r/§/g;s/$/¶/g'"
alias find='find -regextype egrep'

# vi mode

bindkey -v

bindkey jk vi-cmd-mode

# install navi shell widget and change its binding
eval "$(navi widget zsh)"
bindkey -r '^g'
bindkey '^h' _navi_widget

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

# fzf setup. vi mode wipes out the fzf bindings, so make sure to put this after
# vi mode setup. note that fzf bindings only work in insert mode. if one runs
# the fzf install script, all of this is placed in ~/.fzf.(zsh|bash), which is
# sourced from the user's shell rc file, also modified as part of that script.
# however, other methods of installation (via package managers, as a vim plugin,
# etc.) don't offer the option to generate the file. since I'm using fzf as a
# vim plugin, it seems easiest to just directly replicate the contents of
# .fzf.zsh here. an alternative would be to run the install script after fzf is
# already installed, which would cause it to find fzf in the path and create
# simlinks, but that would be an extra step that I don't care to take

FZF_PATH=$HOME/.local/share/nvim/plugged/fzf
# technically this is a bat setting, but I don't use it outside of fzf
export BAT_THEME=gruvbox-dark

# Setup fzf
# ---------
if [[ ! "$PATH" == *$FZF_PATH/bin* ]]; then
  PATH="${PATH:+${PATH}:}$FZF_PATH/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_PATH/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$FZF_PATH/shell/key-bindings.zsh"

# (end fzf setup)

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

# Ring the bell every time a prompt is shown. Useful when a long-running
# process is running in another window. From
# https://stackoverflow.com/a/72182868/12162258. The redirect to $TTY avoids
# angering powerlevel10k's instant prompt feature
precmd() {
  echo -n -e "\a" >$TTY
}

# Don't add commands which trigger command not found to history. From
# https://superuser.com/a/902508/1264067. Note that only simple one line,
# single command cases are covered
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# Note on the below: I'm not quite sure when the highlighting plugin gets
# sourced, but it's definitely before here
# Rough workaround for
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/874
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(regexp)
ZSH_HIGHLIGHT_REGEXP+=('^%\S*' fg=green)
# Also activate the brackets highlighter
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)

# start tmux if conditions met. see
# https://unix.stackexchange.com/a/113768/460319 and
# https://stackoverflow.com/a/69579460/12162258
if command -v tmux &> /dev/null \
   && [ -n "$PS1" ] \
   && [[ ! "$TERM" =~ screen ]] \
   && [[ ! "$TERM" =~ tmux ]] \
   && [[ ! "$TERM" =~ xterm-kitty ]] \
   && [ -z "$TMUX" ] \
   && ! pstree -s $$ | grep -Ewq "code|n?vim"; then
    # previously I had this set up to attach any existing session, but there
    # are good reasons to want multiple terminal windows with distinct sessions
    # open sometimes, e.g. in different workspaces

    # if [[ -n $(pgrep tmux) ]]; then
    #     exec tmux attach
    # else
    #     exec tmux new -s default
    # fi

    # instead, we can start a new, randomly-named session for every window.
    # other sessions can always be freely attached, ended, switched between,
    # etc. using standard methods
    exec tmux new -s "default$RANDOM"
fi
