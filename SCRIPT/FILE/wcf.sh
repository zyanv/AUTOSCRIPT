#!/usr/bin/env bash

# File Location
REPO="https://raw.githubusercontent.com/zyanv/WARP/main/"
websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main
# Clear ui
clear

# download menu
cd /usr/sbin
wget -O warp "${websc}/SCRIPT/FILE/mwcf.sh"
wget -O warp2 "${REPO}warp.sh"

# subcommand
chmod +x warp
chmod +x warp2
