#!/bin/bash
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
NC='\e[0m'



warp_list() {
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/warp-domain.txt")
    if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
        echo ""
        echo "You have no existing domain!"
        sleep 3
        clear
        mwrap
    fi

    clear
    echo ""
    echo -e " ${cy}LIST DOMAIN BYPASS${NC}"
    echo " ==============================="
    echo -e "     ${bb}NO  DOMAIN${NC}   "
    grep -E "^### " "/usr/local/etc/xray/warp-domain.txt" | cut -d ' ' -f 2 | nl -s ') '
    read -n 1 -s -r -p " Press any key to back on menu warp"
    clear
    mwarp
}

domain_add() {
clear
    echo ""
    echo -e " ${cy}SILA MASUKKAN DOMAIN${NC}"
    echo ""
    read -rp "    Enter your Domain/Host: " -e new_dom
    sed -i '/#warp-domain$/a"'"$new_dom"'",' /usr/local/etc/xray/config.json
        sed -i '/#warp-domain$/a"'"$new_dom"'",' /usr/local/etc/xray/none.json

    echo -e "### $new_dom" >> /usr/local/etc/xray/warp-domain.txt

    systemctl restart xray
      systemctl restart xray@none
    clear
    warp_list
}

domain_del() {
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/warp-domain.txt")
    if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
        echo ""
        echo "You have no existing domain!"
        sleep 3
        clear
        mwarp
    fi
    clear
    echo ""
    echo -e " ${cy}LIST DOMAIN TO DELETE${NC}"
    echo " ==============================="
    echo -e "     ${bb}NO  DOMAIN${NC}   "
    grep -E "^### " "/usr/local/etc/xray/warp-domain.txt" | cut -d ' ' -f 2 | nl -s ') '
    until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
        if [[ ${CLIENT_NUMBER} == '1' ]]; then
            read -rp "Select domain [1]: " CLIENT_NUMBER
        else
            read -rp "Select domain [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
        fi
    done
del_dom=$(grep -E "^### " "/usr/local/etc/xray/warp-domain.txt" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/\b$del_dom\b/d" /usr/local/etc/xray/warp-domain.txt
sed -i "/\b$del_dom\b/d" /usr/local/etc/xray/config.json
sed -i "/\b$del_dom\b/d" /usr/local/etc/xray/none.json



systemctl restart xray
systemctl restart xray@none
clear
warp_list
}



# ================= SOCKS5 PROXY MANAGER =================

SOCKS_FILE="/etc/mwarp/socks5-proxy.list"

socks_init(){
    mkdir -p /etc/mwarp
    touch "$SOCKS_FILE"
}

socks_add(){
    socks_init
    clear
    echo "ADD SOCKS5 PROXY"
    read -rp "Name : " name
    echo "Select proxy type:"
    echo "1) socks5"
    echo "2) socks5h"
    read -rp "Type [1-2] : " ptype

    case $ptype in
        2) type="socks5h" ;;
        *) type="socks5" ;;
    esac

    read -rp "Host/IP : " host
    read -rp "Port : " port
    read -rp "Username (optional) : " user
    read -rp "Password (optional) : " pass

    cat >> "$SOCKS_FILE" <<EOF

### $name
type=$type
host=$host
port=$port
user=$user
pass=$pass
status=on
EOF

    echo "Proxy added"
    sleep 2
}

socks_list(){
    socks_init
    clear
    echo "==============================="
    echo " SOCKS5 PROXY LIST"
    echo "==============================="

    if ! grep -q "^### " "$SOCKS_FILE"; then
        echo "No proxy found"
        sleep 2
        return
    fi

    nl=1
    while read -r line; do
        if [[ "$line" == "### "* ]]; then
            name=${line#\#\#\# }
            sed -n "/### $name/,/status=/p" "$SOCKS_FILE" > /tmp/sproxy
            host=$(grep "^host=" /tmp/sproxy | cut -d= -f2)
            port=$(grep "^port=" /tmp/sproxy | cut -d= -f2)
            status=$(grep "^status=" /tmp/sproxy | cut -d= -f2)
            echo "$nl) $name  $host:$port  [$status]"
            ((nl++))
        fi
    done < "$SOCKS_FILE"

    read -n1 -s -r -p "Press any key..."
}

socks_edit(){
    socks_init
    socks_list
    echo ""
    read -rp "Proxy name to edit: " old

    if ! grep -q "^### $old" "$SOCKS_FILE"; then
        echo "Not found"
        sleep 2
        return
    fi

    read -rp "New Host/IP : " host
    read -rp "New Port : " port
    read -rp "New Username : " user
    read -rp "New Password : " pass

    sed -i "/### $old/,/status=/s/^host=.*/host=$host/" "$SOCKS_FILE"
    sed -i "/### $old/,/status=/s/^port=.*/port=$port/" "$SOCKS_FILE"
    sed -i "/### $old/,/status=/s/^user=.*/user=$user/" "$SOCKS_FILE"
    sed -i "/### $old/,/status=/s/^pass=.*/pass=$pass/" "$SOCKS_FILE"

    echo "Updated"
    sleep 2
}

socks_toggle(){
    socks_init
    mode=$1
    socks_list
    echo ""
    read -rp "Proxy name: " name

    if [[ "$mode" == "on" ]]; then
        sed -i "/### $name/,/status=/s/status=.*/status=on/" "$SOCKS_FILE"
    else
        sed -i "/### $name/,/status=/s/status=.*/status=off/" "$SOCKS_FILE"
    fi

    sleep 2
}

socks_delete(){
    socks_init
    socks_list
    echo ""
    read -rp "Proxy name to delete: " name

    sed -i "/### $name/,/### /{/### $name/!d}" "$SOCKS_FILE"
    sed -i "/### $name/d" "$SOCKS_FILE"

    echo "Deleted"
    sleep 2
}

WARP_Proxy_Status=$(curl -sx "socks5h://127.0.0.1:40000" https://www.cloudflare.com/cdn-cgi/trace --connect-timeout 2 | grep warp | cut -d= -f2)                     
if [ "${WARP_Proxy_Status}" == "on" ]                                                     
then                                                                                    
warp_ok=""$gr"ON"$NC""             
else                                                                                    
warp_xok=""$red"OFF"$NC""    
fi 

echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " \033[30;5;47m                      ⇱ SOCKS WRAP MENU ⇲                           \033[m"       
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} " 
echo -e  " "   "" ${cy}WRAP SOCKS STATUS ${NC}" $warp_ok $warp_xok"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} "       
echo -e  " ${bb}[ 01 ] INSTALL SOCKS WRAP "
echo -e  " ${bb}[ 02 ] LIST DOMAIN"
echo -e  " ${bb}[ 03 ] ADD DOMAIN"
echo -e  " ${bb}[ 04 ] DELETE DOMAIN"
echo -e  " ${bb}[ 05 ] UNINSTALL SOCKS WARP"
echo -e  " ${bb}[ 06 ] ADD SOCKS5 PROXY"
echo -e  " ${bb}[ 07 ] LIST SOCKS5 PROXY"
echo -e  " ${bb}[ 08 ] EDIT SOCKS5 PROXY"
echo -e  " ${bb}[ 09 ] ENABLE SOCKS5 PROXY"
echo -e  " ${bb}[ 10 ] DISABLE SOCKS5 PROXY"
echo -e  " ${bb}[ 11 ] DELETE SOCKS5 PROXY"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}" 
echo -e  " ${bb}[  0 ]${NC}" "${cy}EXIT TO MENU${NC}  "
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option :  " warp
echo -e "\e[0m"
 case $warp in
  1)
	clear ; 
    bash <(curl -sSL https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh) ;
    clear 
    mwarp 
  ;;
  2)
    clear ; warp_list
  ;;
  3)
    clear ; domain_add
  ;;
  4)
    clear ; domain_del
  ;;
  5)
    clear ; 
    warp u
    clear 
    mwarp 
  ;;  
  6)
    clear ; socks_add ; mwarp
  ;;
  7)
    clear ; socks_list ; mwarp
  ;;
  8)
    clear ; socks_edit ; mwarp
  ;;
  9)
    clear ; socks_toggle on ; mwarp
  ;;
  10)
    clear ; socks_toggle off ; mwarp
  ;;
  11)
    clear ; socks_delete ; mwarp
  ;;
  0)
  sleep 0.5
  clear
  menu
  ;;
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  mwarp
  ;;
  esac