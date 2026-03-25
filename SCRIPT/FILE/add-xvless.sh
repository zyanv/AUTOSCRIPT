#!/bin/bash
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
wh='\033[0;37m'
NC='\e[0m'
clear

# Create necessary directories if they don't exist
mkdir -p /etc/xray/database/vless

MYIP=$(wget -qO- ipv4.icanhazip.com); 
echo "Checking VPS" 
clear

domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS NON TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			sleep 1
            add-xvless
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH (EXP : wss://bug.com /Press Enter If Only Use Default) : " wss
path=$wss
read -p "Subdomain (EXP : m.google.com. / Press Enter If Only Using Hosts) : " sub
dom=$sub$domain
sed -i '/#xray-vless-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json

echo -e "### $user $exp" $uuid >> /usr/local/etc/xray/vless.txt

# Save account database
cat > /etc/xray/database/vless/$user.txt <<EOF
username: $user
uuid: $uuid
sni: $sni
wss: $wss
expired: $exp
EOF

vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@${dom}:8080?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=bug.com#${user}"
vlesslink5="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://bug.com/#${user}"
vlesslink6="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=bug.com#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#$user"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#$user"

systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp

clear
echo -e ""
echo -e  "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "                         XRAY VLESS WS & XTLS       " 
echo -e  "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}Remarks${NC}          ${cy}:${NC} ${wh}${user}${NC}"
echo -e "${wh}Expired On${NC}       ${cy}:${NC} ${wh}$exp${NC}"
echo -e "${wh}IP/Host${NC}          ${cy}:${NC} ${wh}${MYIP}${NC}"
echo -e "${wh}Domain${NC}           ${cy}:${NC} ${wh}${domain}${NC}"
echo -e "${wh}port TLS${NC}         ${cy}:${NC} ${wh}$tls${NC}"
echo -e "${wh}port none TLS${NC}    ${cy}:${NC} ${wh}$none${NC}"
echo -e "${wh}id${NC}               ${cy}:${NC} ${uuid}${NC}"
echo -e "${wh}Encryption${NC}       ${cy}:${NC} ${wh}none${NC}"
echo -e "${wh}network${NC}          ${cy}:${NC} ${wh}ws${NC}"
echo -e "${wh}path tls${NC}         ${cy}:${NC} ${wh}/xvless${NC}"
echo -e "${wh}path ntls${NC}        ${cy}:${NC} ${wh}/xvlessntls${NC}"
echo -e "${wh}path httpupgrade${NC} ${cy}:${NC} ${wh}/xvless-hup${NC}"
echo -e "${wh}path xhttp${NC}       ${cy}:${NC} ${wh}/xvless-xhttp-ntls${NC}"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS TLS${NC} :"
echo -e ""
echo -e "${cy}${vlesslink1}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS NTLS${NC} : "
echo -e ""
echo -e "${cy}${vlesslink2}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS XTLS${NC} : "
echo -e ""
echo -e "${cy}${vless_vision}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS HTTPUPGRADE${NC} : "
echo -e ""
echo -e "${cy}${vlesslink3}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS XHTTP${NC} : "
echo -e ""
echo -e "${cy}${vlesslink4}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS STRX${NC} : "
echo -e ""
echo -e "${cy}${vlesslink5}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}LINK VLESS XLITE${NC} : "
echo -e ""
echo -e "${cy}${vlesslink6}${NC}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "${wh}ScriptMod By Zyanv${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
