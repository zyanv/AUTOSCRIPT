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
XRAY_CONFIGS=("/usr/local/etc/xray/config.json" "/usr/local/etc/xray/none.json")

socks_init() {
    mkdir -p /etc/mwarp
    touch "$SOCKS_FILE"
}

pause_back() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

proxy_count() { grep -c '^### ' "$SOCKS_FILE" 2>/dev/null || true; }
proxy_names() { grep '^### ' "$SOCKS_FILE" | sed 's/^### //'; }
proxy_block() {
    local name="$1"
    awk -v n="$name" '$0 == "### " n {found=1} found {print} found && /^status=/ {exit}' "$SOCKS_FILE"
}
proxy_value() {
    local name="$1" key="$2"
    proxy_block "$name" | awk -F= -v k="$key" '$1==k {sub(/^[^=]*=/, ""); print; exit}'
}

select_proxy() {
    local count i choice name host port type status
    count=$(proxy_count)
    (( count == 0 )) && { echo "No proxy found."; return 1; }
    i=1
    while IFS= read -r name; do
        host=$(proxy_value "$name" host); port=$(proxy_value "$name" port)
        type=$(proxy_value "$name" type); status=$(proxy_value "$name" status)
        printf '%d) %-18s %-7s %-28s [%s]\n' "$i" "$name" "$type" "$host:$port" "${status^^}"
        ((i++))
    done < <(proxy_names)
    while true; do
        read -rp "Select proxy [1-$count] or 0 to cancel: " choice
        [[ "$choice" == "0" ]] && return 1
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
            proxy_names | sed -n "${choice}p"
            return 0
        fi
        echo "Invalid selection."
    done
}

valid_port() { [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 )); }

socks_add() {
    socks_init; clear; echo "ADD SOCKS PROXY"
    local name ptype type host port user pass
    read -rp "Name: " name
    [[ -z "$name" || "$name" == *"="* ]] && { echo "Invalid name."; pause_back; return; }
    grep -Fxq "### $name" "$SOCKS_FILE" && { echo "Name already exists."; pause_back; return; }
    echo "1) socks5"; echo "2) socks5h"; read -rp "Type [1-2]: " ptype
    [[ "$ptype" == "2" ]] && type="socks5h" || type="socks5"
    read -rp "Host/IP: " host
    read -rp "Port: " port
    valid_port "$port" || { echo "Invalid port."; pause_back; return; }
    read -rp "Username (optional): " user
    read -rsp "Password (optional): " pass; echo
    cat >> "$SOCKS_FILE" <<EOF

### $name
type=$type
host=$host
port=$port
user=$user
pass=$pass
status=off
EOF
    echo "Proxy added as OFF. Use ENABLE to apply it to Xray."; pause_back
}

socks_list() {
    socks_init; clear
    echo "=========================================================================="
    echo " SOCKS PROXY LIST"
    echo "=========================================================================="
    printf '%-4s %-18s %-7s %-28s %-8s\n' "NO" "NAME" "TYPE" "SERVER" "STATUS"
    echo "--------------------------------------------------------------------------"
    local count i=1 name host port type status
    count=$(proxy_count)
    if (( count == 0 )); then echo "No proxy found."; else
        while IFS= read -r name; do
            host=$(proxy_value "$name" host); port=$(proxy_value "$name" port)
            type=$(proxy_value "$name" type); status=$(proxy_value "$name" status)
            printf '%-4s %-18s %-7s %-28s %-8s\n' "$i" "$name" "$type" "$host:$port" "${status^^}"
            ((i++))
        done < <(proxy_names)
    fi
    pause_back
}

socks_edit() {
    socks_init; clear; echo "EDIT SOCKS PROXY"
    local name type host port user pass current ptype escaped
    name=$(select_proxy) || { pause_back; return; }
    current=$(proxy_value "$name" type)
    echo "Current type: $current"; echo "1) socks5"; echo "2) socks5h"
    read -rp "New type [Enter keeps current]: " ptype
    case "$ptype" in 1) type="socks5";; 2) type="socks5h";; *) type="$current";; esac
    current=$(proxy_value "$name" host); read -rp "New Host/IP [$current]: " host; host=${host:-$current}
    current=$(proxy_value "$name" port); read -rp "New Port [$current]: " port; port=${port:-$current}
    valid_port "$port" || { echo "Invalid port."; pause_back; return; }
    current=$(proxy_value "$name" user); read -rp "New Username [$current]: " user; user=${user:-$current}
    read -rsp "New Password [Enter keeps current]: " pass; echo
    [[ -z "$pass" ]] && pass=$(proxy_value "$name" pass)
    escaped=$(printf '%s' "$name" | sed 's/[][\\.^$*+?{}|()]/\\&/g')
    sed -i "/^### $escaped$/,/^status=/ {
        s|^type=.*|type=$type|; s|^host=.*|host=$host|; s|^port=.*|port=$port|;
        s|^user=.*|user=$user|; s|^pass=.*|pass=$pass|
    }" "$SOCKS_FILE"
    echo "Proxy updated. Re-enable it to apply changes to Xray."; pause_back
}

update_xray_socks_server() {
    local host="$1" port="$2" user="$3" pass="$4" file stamp
    stamp=$(date +%Y%m%d%H%M%S)
    for file in "${XRAY_CONFIGS[@]}"; do
        [[ -f "$file" ]] || continue
        cp -a "$file" "$file.bak.$stamp"
        python3 - "$file" "$host" "$port" "$user" "$pass" <<'PYCODE'
import json, os, sys, tempfile
path, host, port, user, password = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5]
lines = open(path, encoding='utf-8').read().splitlines(True)
tag_idx = next((i for i,l in enumerate(lines) if '"tag"' in l and '"socks_out"' in l), None)
if tag_idx is None: raise SystemExit(f'socks_out tag not found in {path}')
servers_idx = next((i for i in range(tag_idx, min(len(lines), tag_idx+80)) if '"servers"' in lines[i]), None)
if servers_idx is None: raise SystemExit(f'servers array not found in {path}')
obj_start = next((i for i in range(servers_idx+1, min(len(lines), servers_idx+20)) if '{' in lines[i]), None)
if obj_start is None: raise SystemExit(f'server object not found in {path}')
depth=0; obj_end=None
for i in range(obj_start, len(lines)):
    depth += lines[i].count('{') - lines[i].count('}')
    if depth == 0: obj_end=i; break
if obj_end is None: raise SystemExit(f'unclosed server object in {path}')
indent = lines[obj_start][:len(lines[obj_start])-len(lines[obj_start].lstrip())]
server={"address":host,"port":port}
if user or password: server["users"]=[{"user":user,"pass":password}]
newline='\n' if lines[obj_start].endswith('\n') else ''
replacement=[indent+x+newline for x in json.dumps(server,indent=4,ensure_ascii=False).splitlines()]
lines[obj_start:obj_end+1]=replacement
fd,tmp=tempfile.mkstemp(prefix='.mwarp-',dir=os.path.dirname(path),text=True)
try:
    with os.fdopen(fd,'w',encoding='utf-8') as f: f.writelines(lines)
    os.chmod(tmp,os.stat(path).st_mode); os.replace(tmp,path)
except Exception:
    try: os.unlink(tmp)
    except OSError: pass
    raise
PYCODE
        [[ $? -eq 0 ]] || { echo "Failed to update $file"; return 1; }
    done
}

restart_xray_services() {
    local failed=0
    systemctl restart xray || failed=1
    systemctl restart xray@none 2>/dev/null || true
    return "$failed"
}

socks_enable() {
    socks_init; clear; echo "ENABLE SOCKS PROXY FOR BYPASS DOMAINS"
    local name host port user pass escaped
    name=$(select_proxy) || { pause_back; return; }
    host=$(proxy_value "$name" host); port=$(proxy_value "$name" port)
    user=$(proxy_value "$name" user); pass=$(proxy_value "$name" pass)
    valid_port "$port" || { echo "Invalid proxy port."; pause_back; return; }
    update_xray_socks_server "$host" "$port" "$user" "$pass" || { echo "Xray config update failed."; pause_back; return; }
    sed -i 's/^status=.*/status=off/' "$SOCKS_FILE"
    escaped=$(printf '%s' "$name" | sed 's/[][\\.^$*+?{}|()]/\\&/g')
    sed -i "/^### $escaped$/,/^status=/s/^status=.*/status=on/" "$SOCKS_FILE"
    if restart_xray_services; then
        echo "Proxy '$name' is ON for domains listed under #warp-domain."
    else
        echo "Proxy applied, but Xray failed to restart. Check systemctl status xray."
    fi
    pause_back
}

socks_disable() {
    socks_init; clear; echo "DISABLE EXTERNAL SOCKS PROXY"
    echo "socks_out will return to local WARP 127.0.0.1:40000."
    local answer
    read -rp "Continue? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return
    update_xray_socks_server "127.0.0.1" "40000" "" "" || { echo "Restore failed."; pause_back; return; }
    sed -i 's/^status=.*/status=off/' "$SOCKS_FILE"
    restart_xray_services
    echo "External proxy is OFF. socks_out now uses 127.0.0.1:40000."; pause_back
}

socks_delete() {
    socks_init; clear; echo "DELETE SOCKS PROXY"
    local name status answer tmp
    name=$(select_proxy) || { pause_back; return; }
    status=$(proxy_value "$name" status)
    [[ "$status" == "on" ]] && { echo "Disable active proxy before deleting it."; pause_back; return; }
    read -rp "Delete '$name'? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return
    tmp=$(mktemp)
    awk -v n="$name" '$0 == "### " n {skip=1; next} skip && /^status=/ {skip=0; next} !skip {print}' "$SOCKS_FILE" > "$tmp" && mv "$tmp" "$SOCKS_FILE"
    echo "Proxy deleted."; pause_back
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
    clear ; socks_enable ; mwarp
  ;;
  10)
    clear ; socks_disable ; mwarp
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