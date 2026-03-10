#!/bin/bash
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

apt -y update 
apt install -y bzip2 gzip coreutils screen curl
sleep 2
clear

# Script Access
echo -e "${gr}CHECKING SCRIPT ACCESS${NC}"
sleep 2
mkdir /etc/pass
clear
read -rp "    MASUKKAN PASSWORD ANDA: " -e pass
IZIN=$(curl https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/IP/permission | grep $pass | awk '{print $2}')
if [ $pass = $IZIN ]; then
    echo -e ""
    echo -e "${gr}ACCESS GRANTED...${NC}"
    echo "$pass" >> /etc/pass/accsess
    sleep 2
else
	echo -e ""
    echo -e "${red}ACCESS DENIED...PM TELEGRAM OWNER${NC}"
    sleep 2
    rm -f setup.sh
    rm -rf /etc/pass
    exit 1
fi
clear
clear

MYIP=$(wget -qO- icanhazip.com);
echo "Checking Vps"
sleep 2
clear

  # // Banner
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e " WELCOME TO ZYANV STORE VPN ${YELLOW}(${NC}${green}Stable Edition${NC}${YELLOW})${NC}"
echo -e " PROSES CHECK IP ADDRESS ANDA !!"
echo -e "${purple}----------------------------------------------------------${NC}"
echo -e " ›AUTHOR : ${green}ZYANV STORE® ${NC}${YELLOW}(${NC}${green}V 3.5${NC}${YELLOW})${NC}"
echo -e " ›TEAM 🅥🅝: ZYANV STORE ${YELLOW}(${NC} 2025 ${YELLOW})${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo ""
sleep 4
clear

#Install Update
echo -e "============================================="
echo -e " ${green} UPDATE && UPGRADE PROCESS${NC}"
echo -e "============================================="
apt -y update 
apt install -y bzip2 gzip coreutils screen curl
sleep 2
clear

# Subdomain Settings
echo -e "============================================="
echo -e "${green} DOMAIN INPUT${NC} "
echo -e "============================================="
sleep 2
mkdir /etc/xray
clear
echo -e ""
echo -e "${green}MASUKKAN DOMAIN ANDA YANG TELAH DI POINT KE IP ANDA${NC}"
read -rp "    Enter your Domain/Host: " -e host
ip=$(wget -qO- ipv4.icanhazip.com)
host_ip=$(ping "${host}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
if [[ ${host_ip} == "${ip}" ]]; then
	echo -e ""
	echo -e "${green}HOST/DOMAIN MATCHED..INSTALLATION WILL CONTINUE${NC}"
    echo "$host" >> /etc/xray/domain
    echo "$host" > /root/domain
	sleep 2
	clear
else
	echo -e "${green}HOST/DOMAIN NOT MATCHED..INSTALLATION WILL TERMINATED${NC}"
	echo -e ""
    rm -f setup.sh
    rm -rf /etc/pass
    exit 1
fi

# Install BBR+FQ
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
clear

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main
#install ssh 
echo -e "============================================="
echo -e " ${green} INSTALLING SSH ${NC}"
echo -e "============================================="
sleep 2
wget ${websc}/SCRIPT/FILE/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
sleep 2
clear

#install dropbear
echo -e "============================================="
echo -e " ${green} INSTALLING DROPBEAR  ${NC}"
echo -e "============================================="
sleep 2
# Install Dropbear
apt install dropbear -y
bash <(curl -s https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/dropbear.sh)
rm -f /etc/dropbear/dropbear_rsa_host_key
dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
rm -f /etc/dropbear/dropbear_dss_host_key
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
rm -f /etc/dropbear/dropbear_ecdsa_host_key
dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key
cd /etc/default
rm -f dropbear
wget -qO dropbear "https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/dropbear.conf"
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
echo -e "Dev @Rerechan02" > /etc/issue.net
clear
systemctl daemon-reload
/etc/init.d/dropbear restart
clear
cd /root
rm -fr dropbear*
sleep 2
clear


#install udp custom
echo -e "============================================="
echo -e " ${green} INSTALLING UDP CUSTOM  ${NC}"
echo -e "============================================="
sleep 2
# Setup UDP Custom
bash <(curl -s https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/udp.sh)
sleep 2
clear

#install xcore changer
echo -e "============================================="
echo -e " ${green} INSTALLING XRAY CHANGER  ${NC}"
echo -e "============================================="
sleep 2
wget -q -O /usr/bin/xcorechanger "https://raw.githubusercontent.com/NiL070/XrayCoreChanger/main/xcorechanger.sh" && chmod +x /usr/bin/xcorechanger
sleep 2
clear

#install xcore changer
echo -e "============================================="
echo -e " ${green} INSTALLING XRAY CHANGER  ${NC}"
echo -e "============================================="
sleep 2
wget -q -O /usr/bin/xcorechanger "https://raw.githubusercontent.com/NiL070/XrayCoreChanger/main/xcorechanger.sh" && chmod +x /usr/bin/xcorechanger
sleep 2
clear

#install Xray
echo -e "============================================="
echo -e " ${green} INSTALLING XRAY${NC} "
echo -e "============================================="
sleep 2
wget ${websc}/SCRIPT/FILE/install-xray.sh && chmod +x install-xray.sh && ./install-xray.sh
sleep 2
clear

#install warp
#echo -e "============================================="
#echo -e " ${green} INSTALLING WARP SOCKS${NC} "
#echo -e "============================================="
#sleep 2
#wget git.io/warp.sh
#clear

#install resolv
echo -e "============================================="
echo -e " ${green} INSTALLING RESOLVCONF${NC} "
echo -e "============================================="
sleep 2
apt install resolvconf -y
systemctl start resolvconf.service
systemctl enable resolvconf.service
echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/head
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
systemctl restart resolvconf.service
clear
echo -e " ${red}RESOLVE INSTALL DONE ${NC}"
sleep 2
clear

# // Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

clear

rm -f /root/ssh-vpn.sh
rm -f /root/install-xray.sh
rm -f /root/websocket.sh

clear
echo " "
echo "INSTALLATION COMPLETE!!"
echo " "
echo "====================== ZYANVVPN AUTOSCRIPT =======================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - XRAY VLESS WS TLS            : 443"  | tee -a log-install.txt
echo "   - XRAY VLESS XTLS              : 443"  | tee -a log-install.txt
echo "   - XRAY VLESS GRPC              : 443"  | tee -a log-install.txt
echo "   - XRAY VLESS WS NON TLS        : 80"  | tee -a log-install.txt
echo "   - XRAY VLESS HTTPUPG NON TLS   : 80"  | tee -a log-install.txt
echo "   - XRAY VLESS XHTTP NON TLS     : 8080"  | tee -a log-install.txt
echo "   - SSH WEBSOCKET HTTP           : 8880"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "===================================================================="
echo ""  | tee -a log-install.txt
echo "   - Telegram                : t.me/ZYANV 2000"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "========================== SCRIPT BY ZYANV 2000 =====================" | tee -a log-install.txt
echo ""
sleep 1
rm -f setup.sh
read -n 1 -r -s -p $'Press any key to reboot...\n';reboot
