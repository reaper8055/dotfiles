#!/usr/bin/env bash

# Function to start the daemon
start_daemon() {
  while true; do
    current_checksum=$(md5sum "$config_file")
    if [[ "$current_checksum" != "$previous_checksum" ]]; then
      diff_output=$(diff -u <(echo "$previous_content") <(echo "$current_content"))
      while IFS= read -r line; do
        if [[ $line =~ ^[+\-] ]]; then
          echo "$line" >> "$tmp_file"
        fi
      done <<< "$diff_output"
      source "$tmp_file" && rm -f "$tmp_file"
      previous_content=$(<"$config_file")
      previous_checksum="$current_checksum"
    fi
    sleep 5  # Adjust the frequency of checking the file for changes
  done
}

# Main script starts here
config_file="$HOME/.zshrc"
previous_checksum=""
current_checksum=""
previous_content=$(<"$config_file")
tmp_file="/tmp/diffrc.$$"

# Check if the script is already running
if pidof -x "$(basename "$0")" >/dev/null; then
  echo "Script is already running." >&2
  exit 1
fi

# Start the daemon
start_daemon &
