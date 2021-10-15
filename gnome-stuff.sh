#!/usr/bin/env bash
# USAGE: ./gnome-stuff.sh
# Note that there are a few manual steps that I couldn't automate:
# - Configure weather location (logout to enable in top bar)
# - Open tweaks and set theme to Adwaita-dark
# - Install Clock Override extension and set format string to %A %B %e %l:%M:%S
# - Connect google account for calendar (online accounts)
# - Turn off terminal bell in term preferences, and set font to Menlo for
#   Powerline, size 11
# - Change alt/super-tab behavior. Settings->Devices->Keyboard->Switch windows/applications
# - If running with multiple monitors, set tweaks->Workspaces->Workspaces Span Displays
# - To enhance window tiling, follow https://askubuntu.com/a/1089033/1014459
# - Turn repeat keys delay down to at least tmux repeat-time. See
#   https://help.ubuntu.com/stable/ubuntu-help/keyboard-repeat-keys.html.en for
#   details

sudo apt-get install gnome-weather gnome-tweaks
# if the system is dual boot with windows, run this (from
# https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/
# ) to fix windows time going awry everytime linux is booted
# timedatectl set-local-rtc 1 --adjust-system-clock
# in reverse:
# timedatectl set-local-rtc 0 --adjust-system-clock
