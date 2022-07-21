#!/usr/bin/env zsh
# There are a handful of commands that need to be run in the Oh-My-Zsh context,
# i.e. with access to its environment and variables. This script begins by
# sourcing oh-my-zsh.sh, so any such commands can be kept here. It must of
# course be run after Oh-My-Zsh is installed and in the default location

source ~/.oh-my-zsh/oh-my-zsh.sh

# poetry tab completion. see
# https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh
mkdir -p $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry

