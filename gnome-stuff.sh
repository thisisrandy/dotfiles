#!/usr/bin/env bash
# USAGE: ./gnome-stuff.sh
# Note that there are a few manual steps that I couldn't automate:
# - Configure weather location (logout to enable in top bar)
# - Open tweaks and set theme to Adwaita-dark
# - Install Clock Override extension and set format string to %A %B %e %l:%M:%S
# - Connect google account for calendar (online accounts)
# - Turn off terminal bell in term preferences

sudo apt-get install gnome-weather gnome-tweaks
