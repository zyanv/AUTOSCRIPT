#!/usr/bin/env bash

# File Location
file="https://raw.githubusercontent.com/FN-Rerechan02/warp-cloudflare/refs/heads/main/"

# Clear ui
clear

# download menu
cd /usr/sbin
wget -O warp "${file}menu.sh"
wget -O warp2 "${file}warp.sh"

# subcommand
chmod +x warp
chmod +x warp2
