# USAGE: ZSH_CUSTOM=$ZSH_CUSTOM ./zsh-install.sh
#
# It's unclear how to run scripts in the context of Oh-My-Zsh, which creates a
# bunch of variables w/o exporting them to the environment. It's also unclear
# if the main installer script has any opportunity to invoke things in the OMZ
# context. In lieu of a better option, this script can be invoked manually from
# OMZ as specified in the USAGE

# poetry tab completion. see
# https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh
mkdir -p $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry

