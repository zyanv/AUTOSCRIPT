#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

#delete file
rm -f /usr/local/bin/menu
rm -f /usr/local/bin/mray
rm -f /usr/local/bin/mssh

# download script
cd /usr/local/bin
wget -O menu "${websc}/SCRIPT/FILE/menu.sh" && chmod +x menu
wget -q -O /usr/local/bin/mray "${websc}/SCRIPT/FILE/mray.sh" && chmod +x cd/usr/local/bin/mxray
wget -q -O /usr/local/bin/mssh "${websc}/SCRIPT/FILE/mssh.sh" && chmod +x cd/usr/local/bin/mssh
clear
