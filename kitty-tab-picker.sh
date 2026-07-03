#!/usr/bin/env bash

# Use the environment socket Kitty automatically provides to the window
if [ -n "$KITTY_LISTEN_ON" ]; then
  SOCKET_STR="--to=$KITTY_LISTEN_ON"
else
  SOCKET_STR=""
fi

# Fetch all tabs in JSON format
json_data=$(kitty @ $SOCKET_STR ls 2>/dev/null)
if [ -z "$json_data" ]; then
  echo "Error: Kitty remote control is not responding."
  echo "Ensure 'allow_remote_control yes' is set in kitty.conf"
  read -n 1
  exit 1
fi

# Parse JSON safely
selected_tab=$(echo "$json_data" | jq -r '.[] | .tabs[] | "\(.id) \(.title)"' 2>/dev/null | fzf --with-nth=2.. --preview-window=hidden)

# Extract the ID and focus the selected tab
if [ -n "$selected_tab" ]; then
  tab_id=$(echo "$selected_tab" | awk '{print $1}')
  kitty @ $SOCKET_STR focus-tab --match id:"$tab_id"
fi
