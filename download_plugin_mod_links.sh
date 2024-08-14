#!/usr/bin/env bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Stop script on errors
set -e

# Dependencies
add-apt-repository ppa:rmescandon/yq -y
apt update
apt install yq -y

# Paths for mods and plugins
MODS_DIR="./mods"
PLUGINS_DIR="./plugins"

# Create directories if they don't exist
mkdir -p "$MODS_DIR" "$PLUGINS_DIR"

# Function to download files
download_file() {
  local dir="$1"
  local name="$2"
  local link="$3"

  # Check if any file in the directory contains the name
  if ! ls "$dir" | grep -q "$name"; then
    echo "Downloading $name from $link..."
    curl -o "$dir/$name" "$link"
  else
    echo "$name is already present in $dir."
  fi
}

# Parsing the YAML file
YAML_FILE="plugin_mod_links.yaml"

# Download mods
# for mod in $(yq e '.mods[] | .name + "," + .link' "$YAML_FILE"); do
#   IFS=',' read -r name link <<< "$mod"
#   download_file "$MODS_DIR" "$name" "$link"
# done

# Download plugins
for plugin in $(yq e '.plugins[] | .name + "," + .link' "$YAML_FILE"); do
  IFS=',' read -r name link <<< "$plugin"
  download_file "$PLUGINS_DIR" "$name" "$link"
done

echo "Download process completed."
