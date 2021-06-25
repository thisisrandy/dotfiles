#!/usr/bin/env zsh
# USAGE: ./zsh-install.sh
# NOTES:
#   - Certain setup commands need to be run in zsh and not bash. This script
#     exists to run those commands
#   - This script is intended to be run after install.sh is complete. In fact,
#     the last thing install.sh does is invoke this script. As such, it should
#     not be run twice, though doing so may not harm anything

# poetry tab completion. see
# https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry

# pipx completions
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"


