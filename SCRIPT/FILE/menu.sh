#!/bin/bash
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
wh='\033[0;37m'
NC='\e[0m'
clear

# --- Bandwidth Usage (vnstat) ---
read_vnstat_usage() {
  local interface=$1
  local today=$(vnstat -i "$interface" | grep "today" | awk '{print $8" "$9}')
  local yesterday=$(vnstat -i "$interface" | grep "yesterday" | awk '{print $8" "$9}')
  local this_month=$(vnstat -i "$interface" -m | grep "$(date +"%b '%y")" | awk '{print $9" "$10}')
  echo "$today;$yesterday;$this_month"
}

convert_to_mb() {
  local value=$1
  local unit=$2
  case $unit in
    B) echo "scale=6; $value / 1048576" | bc ;;
    KiB) echo "scale=6; $value / 1024" | bc ;;
    MiB) echo "$value" ;;
    GiB) echo "scale=6; $value * 1024" | bc ;;
    TiB) echo "scale=6; $value * 1048576" | bc ;;
    *) echo "0" ;;
  esac
}

all_interfaces=$(vnstat --iflist 2>/dev/null | sed 's/Available interfaces: //')
if [ -z "$all_interfaces" ]; then
  ttoday="N/A"
  tyest="N/A"
  tmon="N/A"
else
  total_today=0
  total_yesterday=0
  total_month=0

  for iface in $all_interfaces; do
    result=$(read_vnstat_usage "$iface")
    today=$(echo "$result" | awk -F';' '{print $1}')
    yesterday=$(echo "$result" | awk -F';' '{print $2}')
    month=$(echo "$result" | awk -F';' '{print $3}')
    
    today_value=$(echo "$today" | awk '{print $1}')
    today_unit=$(echo "$today" | awk '{print $2}')
    yesterday_value=$(echo "$yesterday" | awk '{print $1}')
    yesterday_unit=$(echo "$yesterday" | awk '{print $2}')
    month_value=$(echo "$month" | awk '{print $1}')
    month_unit=$(echo "$month" | awk '{print $2}')
    
    total_today=$(echo "$total_today + $(convert_to_mb $today_value $today_unit)" | bc)
    total_yesterday=$(echo "$total_yesterday + $(convert_to_mb $yesterday_value $yesterday_unit)" | bc)
    total_month=$(echo "$total_month + $(convert_to_mb $month_value $month_unit)" | bc)
  done

  format_usage() {
    local value=$1
    if (( $(echo "$value >= 1024" | bc -l) )); then
      echo "$(printf "%.2f" $(echo "$value / 1024" | bc)) GB"
    else
      echo "$(printf "%.2f" $value) MB"
    fi
  }

  ttoday=$(format_usage "$total_today")
  tyest=$(format_usage "$total_yesterday")
  tmon=$(format_usage "$total_month")
fi


today=`date -d "0 days" +"%Y-%m-%d"`

IPVPS=$(curl -s icanhazip.com)
DOMAIN=$(cat /etc/xray/domain)
cekxray="$(openssl x509 -dates -noout < /usr/local/etc/xray/xray.crt)"                                      
expxray=$(echo "${cekxray}" | grep 'notAfter=' | cut -f2 -d=)
xcore="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')"

usersc=$(cat /etc/pass/accsess)

usrvl="$gr$(grep -o -i "###" /usr/local/etc/xray/vless.txt | wc -l)$NC"
usrovpn="$gr$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)$NC"

clear
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " \033[30;5;47m                         ⇱ SCRIPT ZYANV ⇲                        \033[m"      
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  "  ${wh}IP VPS NUMBER${NC}                    ${cy}:${NC} ${wh}$IPVPS${NC}"
echo -e  "  ${wh}DOMAIN${NC}                           ${cy}:${NC} ${wh}$DOMAIN${NC}"
echo -e  "  ${wh}OS VERSION${NC}                       ${cy}:${NC} ${wh}`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`"${NC}
echo -e  "  ${wh}KERNEL VERSION${NC}                   ${cy}:${NC} ${wh}`uname -r`${NC}"
echo -e  "  ${wh}XRAY CORE VERSION${NC}                ${cy}:${NC} ${wh}$xcore${NC}"
echo -e  "  ${wh}EXP DATE CERT XRAY${NC}               ${cy}:${NC} ${wh}$expxray${NC}"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " ${cy}PROTOCOL    ${wh}SSH/OVPN      VLESS            Bandwith Usage${NC}    "
echo -e  " ${cy}TOTAL USER${NC}    [$usrovpn]          [$usrvl]    [$ttoday] [$tyest] [$tmon]"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " \033[30;5;47m                         ⇱ SSHWS/OVPN MENU ⇲                     \033[m"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${wh}[ 01 ]${NC} ${cy}CREATE NEW USER${NC}            ${wh}[ 06 ]${NC} ${cy}LIST USER INFORMATION${NC}"
echo -e  " ${wh}[ 02 ]${NC} ${cy}CREATE TRIAL USER${NC}          ${wh}[ 07 ]${NC} ${cy}SET AUTO KILL LOGIN${NC}"
echo -e  " ${wh}[ 03 ]${NC} ${cy}EXTEND ACCOUNT ACTIVE${NC}      ${wh}[ 08 ]${NC} ${cy}DISPLAY USER MULTILOGIN${NC}"
echo -e  " ${wh}[ 04 ]${NC} ${cy}DELETE ACTIVE USER${NC}         ${wh}[ 09 ]${NC} ${cy}INSTALL SSHWS${NC}"
echo -e  " ${wh}[ 05 ]${NC} ${cy}CHECK USER LOGIN${NC}"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " \033[30;5;47m                         ⇱ XRAY MENU ⇲                           \033[m"       
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} " 
echo -e  " ${wh}[ 10 ]${NC} ${cy}CREATE NEW USER${NC}            ${wh}[ 14 ]${NC}"" ${cy}CHECK USER LOGIN${NC}"
echo -e  " ${wh}[ 11 ]${NC} ${cy}CREATE TRIAL USER${NC}          ${wh}[ 15 ]${NC}"" ${cy}LIST USER${NC}"
echo -e  " ${wh}[ 12 ]${NC} ${cy}EXTEND ACCOUNT ACTIVE${NC}      ${wh}[ 16 ]${NC}"" ${cy}RENEW XRAY CERTIFICATION${NC}"
echo -e  " ${wh}[ 13 ]${NC} ${cy}DELETE ACTIVE USER${NC}"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " \033[30;5;47m                         ⇱ SYSTEM MENU ⇲                         \033[m"      
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${wh}[ 17 ]${NC} ${cy}ADD/CHANGE DOMAIN VPS${NC}      ${wh}[ 23 ]${NC} ${cy}SPEEDTEST VPS${NC}"
echo -e  " ${wh}[ 18 ]${NC} ${cy}CHANGE DNS SERVER${NC}          ${wh}[ 24 ]${NC} ${cy}CHECK STREAM GEO LOCATION${NC}"
echo -e  " ${wh}[ 19 ]${NC} ${cy}RESTART ALL SERVICE${NC}        ${wh}[ 25 ]${NC} ${cy}DISPLAY SYSTEM INFORMATION${NC}"
echo -e  " ${wh}[ 20 ]${NC} ${cy}CHECK BANDWITH${NC}             ${wh}[ 26 ]${NC} ${cy}SERVICE STATUS${NC}"
echo -e  " ${wh}[ 21 ]${NC} ${cy}MENU AUTO REBOOT${NC}           ${wh}[ 27 ]${NC} ${cy}SOCKS WRAP${NC}" 
echo -e  " ${wh}[ 22 ]${NC} ${cy}WARP CLOUDFLARE${NC}            ${wh}[ 28 ]${NC} ${cy}CHANGE XRAY CORE${NC}" 
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC}" 
echo -e  " ${wh}[  0 ]${NC}" "${cy}EXIT MENU${NC}  "
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " ${cy}══════════════════════════════════${NC}"
echo -e  " ${wh}SCRIPT VERSION${NC} ${cy}:${NC} ${wh}LIFETIME${NC}"
echo -e  " ${wh}USED BY${NC}        ${cy}:${NC} ${wh}$usersc${NC}"
echo -e  " ${cy}══════════════════════════════════${NC}"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option : " menu
echo -e "\e[0m"
 case $menu in
  1)
  clear ; usernew
  ;;
  2)
  clear ; trial 
  ;;
  3)
  clear ; renew
  ;;
  4)
  clear ; hapus
  ;;
  5)
  clear ; cek
  ;;
  6)
  clear ; member
  ;;
  7)
  clear ; autokill
  ;;
  8)
  clear ; ceklim
  ;;
  9)
  clear ; ./install_ws_http.sh install
  ;;
  10)
  clear ; add-xvless
  ;;
  11)
  clear ; trial-xvless
  ;;
  12)
  clear ; renew-xvless
  ;;
  13)
  clear ; del-xvless
  ;; 
  14)
  clear ; cek-xvless
  ;;
  15)
  clear ; vless-list
  ;;
  16)
  clear ; recert-xray
  ;;    
  17)
  clear ; add-host
  ;;
  18)
  clear ; mdns
  ;;
  19)
  clear ; restart-service
  ;;
  20)
  clear ; vnstat
  ;;
  21)
  clear ; autoreboot
  ;;
  22)
  clear ; cf
  ;;
  23)
  clear ; speedtest
  ;;
  24)
  clear ; nf
  ;;
  25)
  clear ; info
  ;;
  26)
  clear ; status
  ;;
  27)
  clear ; mwarp
  ;;
  28)
  clear ; xcorechanger
  ;;
  0)
  sleep 0.5
  clear
  exit
  ;;
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  menu
  ;;
  esac
