#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

#delete file
rm -f /usr/local/bin/menu
# download script
cd /usr/local/bin
wget -O menu "${websc}/SCRIPT/FILE/menu.sh" && chmod +x menu
wget -O mray "${websc}/SCRIPT/FILE/mray.sh" && chmod +x mray
wget -O mssh "${websc}/SCRIPT/FILE/mssh.sh" && chmod +x mssh
cd
clear
