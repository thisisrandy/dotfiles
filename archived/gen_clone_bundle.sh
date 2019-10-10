#!/bin/bash

bundle_dir="$HOME/.vim/bundle"
bundle_dir_generic="~/.vim/bundle"
clone_script="$PWD/clone_bundle.sh"
non_git_bundle="$PWD/non_git_bundle.txt"

if [ -e $clone_script ]; then
    rm -f $clone_script
fi
if [ -e $non_git_bundle ]; then
    rm -f $non_git_bundle
fi

echo "cd $bundle_dir_generic" >> $clone_script
for dir in $bundle_dir/*; do
    if [ -d $dir/.git ]; then
        cd $dir
        git remote show origin \
            | perl -ne 'print "git clone $1\n" if /Fetch URL: (.*github.*)$/' \
            >> $clone_script
    else
        echo $dir | sed 's/.*\///' >> $non_git_bundle
    fi
done

chmod +x $clone_script
