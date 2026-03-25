#!/bin/bash
clear

websc=https://raw.githubusercontent.com/JinGGoVPN/DATA/main

#delete file
rm -f /usr/local/bin/add-xvless
rm -f /usr/local/bin/trial-xvless
# download script
cd /usr/local/bin
wget -O add-xvless "${websc}/script/lifetime/upgrade/add-xvless.sh" && chmod +x add-xvless
wget -O trial-xvless "${websc}/script/lifetime/upgrade/trial-xvless.sh" && chmod +x trial-xvless
cd
clear