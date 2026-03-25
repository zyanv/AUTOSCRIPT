#!/bin/bash
# ========================================================
# VIEW VLESS ACCOUNT DETAILS
# ========================================================

MYIP=$(wget -qO- ipv4.icanhazip.com); 
echo "Checking VPS" 
clear

clear
domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS NON TLS" | cut -d: -f2|sed 's/ //g')"

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[037;1m"
echo -e "\e[0;41;36m              VIEW VLESS ACCOUNT DETAILS                  \e[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[037;1m"

# Display all users with expiration info
echo -e "Username\t\tExpired Date\t\tDays Remaining"
echo -e "────────────────────────────────────────────────────────────────"

# Check if database directory exists
if [[ ! -d "/etc/xray/database/vless" ]]; then
    echo "Database directory not found!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
    exit 0
fi

# Function to calculate days remaining
calculate_days_remaining() {
    local exp_date="$1"
    # Convert YYYY-MM-DD-HH-MM-SS to YYYY-MM-DD for date comparison (only date part)
    local exp_date_only=$(echo "$exp_date" | cut -d'-' -f1-3)
    local current_date=$(date +%Y-%m-%d)
    
    local exp_timestamp=$(date -d "$exp_date_only" +%s 2>/dev/null)
    local current_timestamp=$(date -d "$current_date" +%s)
    
    if [[ -n "$exp_timestamp" ]]; then
        local diff_seconds=$((exp_timestamp - current_timestamp))
        local days_remaining=$((diff_seconds / 86400))
        if [[ $days_remaining -lt 0 ]]; then
            echo "0"
        else
            echo "$days_remaining"
        fi
    else
        echo "Invalid"
    fi
}

# Get list of user files
user_files=$(ls /etc/xray/database/vless/ 2>/dev/null)

if [[ -z "$user_files" ]]; then
    echo "No VLESS users found in database!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
    exit 0
fi

# Display user list from database files
for user_file in $user_files; do
    if [[ -f "/etc/xray/database/vless/$user_file" ]]; then
        username=$(echo "$user_file" | sed 's/\.txt$//')
        exp_date=$(grep "^expired:" "/etc/xray/database/vless/$user_file" | cut -d' ' -f2-)
        
        if [[ -n "$exp_date" && "$exp_date" != " " ]]; then
            days_remaining=$(calculate_days_remaining "$exp_date")
            printf "%-20s\t%s\t%s\n" "$username" "$exp_date" "$days_remaining"
        fi
    fi
done

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[037;1m"

# Get username to view details
read -rp "Enter username to view details: " view_user

# Check if user exists in database
if [[ ! -f "/etc/xray/database/vless/${view_user}.txt" ]]; then
    echo "User '$view_user' not found in database!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    menu
    exit 0
fi

# Read account details from database
username=$(grep "^username:" "/etc/xray/database/vless/${view_user}.txt" | cut -d' ' -f2-)
uuid=$(grep "^uuid:" "/etc/xray/database/vless/${view_user}.txt" | cut -d' ' -f2-)
sni=$(grep "^sni:" "/etc/xray/database/vless/${view_user}.txt" | cut -d' ' -f2-)
wss=$(grep "^wss:" "/etc/xray/database/vless/${view_user}.txt" | cut -d' ' -f2-)
expired=$(grep "^expired:" "/etc/xray/database/vless/${view_user}.txt" | cut -d' ' -f2-)

# Generate links
vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@${dom}:8080?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=bug.com#${user}"
vlesslink5="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://bug.com/#${user}"
vlesslink6="vless://${uuid}@bug.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=bug.com#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#${user}"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#${user}"

# Clear screen and display account details
clear
echo -e ""
echo -e  "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "                             XRAY VLESS WS & XTLS       " 
echo -e  "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "Remarks          : ${user}"
echo -e "Expired On       : $exp"
echo -e "IP/Host          : ${MYIP}"
echo -e "Domain           : ${domain}"
echo -e "port TLS         : $tls"
echo -e "port none TLS    : $none"
echo -e "id               : ${uuid}"
echo -e "Encryption       : none"
echo -e "network          : ws"
echo -e "path tls         : /xvless"
echo -e "path ntls        : /xvlessntls"
echo -e "path httpupgrade : /xvless-hup"
echo -e "path xhttp       : /xvless-xhttp-ntls"
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS TLS :"
echo -e ""
echo -e "${vlesslink1}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS NTLS : "
echo -e ""
echo -e "${vlesslink2}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS XTLS : "
echo -e ""
echo -e "${vless_vision}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e ""
echo -e "${vlesslink3}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS XHTTP : "
echo -e ""
echo -e "${vlesslink4}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS STRX : "
echo -e ""
echo -e "${vlesslink5}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "LINK VLESS XLITE : "
echo -e ""
echo -e "${vlesslink6}"
echo -e ""
echo -e "${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e "ScriptMod By Zyanv"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
