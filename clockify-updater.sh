#!/bin/bash

set -xeu

cd $(mktemp -d)
wget https://clockify.me/downloads/Clockify_Setup_x64.deb
yes | sudo dpkg -i Clockify_Setup_x64.deb
