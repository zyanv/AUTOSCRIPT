#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

#delete file
rm -f /usr/local/bin/menu-tweak

# download script
cd /usr/local/bin
wget -O menu-tweak "${websc}/SCRIPT/FILE/menu-tweak.sh" && chmod +x menu-tweak
clear
