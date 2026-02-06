#!/bin/bash
#Autoscript-Lite By ZyanV
clear
MYIP=$(wget -qO- ipv4.icanhazip.com);
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
        if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
                echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
                echo -e "\\E[0;41;36m    Check XRAY Vless WS Config     \E[0m"
                echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
                echo ""
                echo "You have no existing clients!"
                clear
                exit 1
i=1

while [[ $i -le $NUMBER_OF_CLIENTS ]]; do
    user=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${i}"p)
    exp=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${i}"p)
    days_left=$(( ( $(date -d "$exp" +%s) - $(date -d "today" +%s) ) / 86400 ))

    printf "%2d  %-15s %-20s %4d\n" $i "$exp" "$user" $days_left
    i=$((i + 1))
done

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
        if [[ ${CLIENT_NUMBER} == '1' ]]; then
            read -rp "Select one client [1] (or 'x' to return to menu): " CLIENT_NUMBER
            if [[ "${CLIENT_NUMBER}" == "x" ]]; then
                return  # Go back to the calling function
            fi
        else
            echo -e ""
            read -rp "Select one client [1-${NUMBER_OF_CLIENTS}] 
(or 'x' to return to menu): " CLIENT_NUMBER
            if [[ "${CLIENT_NUMBER}" == "x" ]]; then
                menu
            fi
        fi
    done
    
###REST OF SCRIPT BELOW
clear
user=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
tls="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS NON TLS" | cut -d: -f2|sed 's/ //g')"
domain=$(cat /etc/xray/domain)
uuid=$(grep "},{" /usr/local/etc/xray/config.json | cut -b 11-46 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`

vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://bug.com/#${user}"
vlesslink5="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=bug.com#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#$user"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#$user"

clear
clear
echo -e ""
echo -e  " ${cy}══════════════════════════════════${NC}"
echo -e "   ${wh}XRAY VLESS WS & XTLS${NC}       " 
echo -e  " ${cy}══════════════════════════════════${NC}"
echo -e "${wh}Remarks${NC}        ${cy}:${NC} ${wh}${user}${NC}"
echo -e "${wh}Expired On${NC}     ${cy}:${NC} ${wh}$exp${NC}"
echo -e "${wh}IP/Host${NC}        ${cy}:${NC} ${wh}${MYIP}${NC}"
echo -e "${wh}Domain${NC}         ${cy}:${NC} ${wh}${domain}${NC}"
echo -e "${wh}port TLS${NC}       ${cy}:${NC} ${wh}$tls${NC}"
echo -e "${wh}port none TLS${NC}  ${cy}:${NC} ${wh}$none${NC}"
echo -e "${wh}id${NC}             ${cy}:${NC} ${wh}${uuid}${NC}"
echo -e "${wh}Encryption${NC}     ${cy}:${NC} ${wh}none${NC}"
echo -e "${wh}network${NC}        ${cy}:${NC} ${wh}ws${NC}"
echo -e "${wh}path${NC}           ${cy}:${NC} ${wh}/xvless${NC}"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS TLS${NC} :"
echo -e "\`\`\`"
echo -e "${wh}${vlesslink1}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS NTLS${NC} : "
echo -e "\`\`\`"
echo -e "${wh}${vlesslink2}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS XTLS${NC} : "
echo -e "\`\`\`"
echo -e "${wh}${vless_vision}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS HTTPUPGRADE${NC} : "
echo -e "\`\`\`"
echo -e "${wh}${vlesslink3}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS WEBSOCKET STRX${NC} : "
echo -e "\`\`\`"
echo -e "${wh}${vlesslink4}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "${wh}LINK VLESS WEBSOCKET XLITE${NC} : "
echo -e "\`\`\`"
echo -e "${wh}${vlesslink5}${NC}"
echo -e "\`\`\`"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e "ScriptMod By ZYANV"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu