#!/bin/bash
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

#delete file
rm -f /usr/local/bin/add-xvless
# download script
cd /usr/local/bin
wget -O add-xvless "${websc}/SCRIPT/FILE/add-xvless.sh" && chmod +x add-xvless
cd
clear
