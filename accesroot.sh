#!/bin/bash
# xixi
# echo "$crot    ALL=(ALL:ALL) ALL" >> /etc/sudoers;
wget -q -O /tmp/sshd_config https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/sshd_config && sudo mv /tmp/sshd_config /etc/ssh/sshd_config;
systemctl restart ssh;
clear;
echo -e "Enter Password:";
read -e pwe;
usermod -p "$(perl -e "print crypt('$pwe', 'Q4')")" root;
clear;
printf "Save This Vps Information
============================================
Root Account (Main Account)
Ip address = $(curl -Ls http://ipinfo.io/ip)
Username   = root
Password   = $pwe
============================================
"
echo "";
exit;
