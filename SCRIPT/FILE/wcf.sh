#!/bin/bash

# install basic package
#apt install resolvconf -y 

# install clouflare JQ
#apt install jq curl -y

# reload wg
#cat << 'EOF' > /root/restart_wg
#!/bin/sh
#bash warp2 wgd

#EOF

#sleep 1
#clear

#chmod +x /root/restart_wg
# reload wg 0630 am
#echo "#30 6 * * * root /root/restart_wg" >> /etc/crontab
clear

# download menu
cd /usr/sbin
wget -O warp "${websc}/SCRIPT/FILE/mwcf.sh"
wget -O warp2 "${REPO}warp.sh"

# subcommand
chmod +x warp
chmod +x warp2

warp
