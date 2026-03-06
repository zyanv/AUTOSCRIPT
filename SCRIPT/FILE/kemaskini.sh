#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

#delete file
rm -f /usr/local/bin/menu
# download script
cd /usr/local/bin
wget -O menu "${websc}/SCRIPT/FILE/menu.sh" && chmod +x menu
cd
clear