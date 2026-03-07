#!/bin/bash
# =========================================
# IPv4 + IPv6 Toggle (rc.local Method)
# Date: 2026-02-21
# Author: NevermoreSSH
# =========================================

RCLOCAL="/etc/rc.local"

# ===== COLOR =====
line="38;5;208"
GREEN="\e[92m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
reset="\e[0m"
title="\e[30;107m"

# if no IPv6
IPVPS=$(curl -s ipv4.icanhazip.com || curl -s ipinfo.io/ip || curl -s ifconfig.me)
IPV6=$(curl -s -6 ipv6.icanhazip.com)

if [ -z "$IPV6" ]; then
    IPV6="\e[32m(IPv4 only)\e[0m"
else
    IPV6="\e[32m($IPV6)\e[0m"
fi

# ===== Detect IPv4 =====
IPV4=$(hostname -I | awk '{print $1}')

# ===== Detect IPv6 Status =====
STATUS_IPV6=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)

if [ "$STATUS_IPV6" = "1" ]; then
    IPV6_STATUS="Disabled"
    IPV6_GLOBAL="Disabled"
    IPV6_LL="Disabled"
else
    IPV6_STATUS="Enabled"
    IPV6_GLOBAL=$(ip -6 addr show scope global | awk '/inet6/ {print $2}')
    IPV6_LL=$(ip -6 addr show scope link | awk '/inet6/ {print $2}')
    [ -z "$IPV6_GLOBAL" ] && IPV6_GLOBAL="Offline"
    [ -z "$IPV6_LL" ] && IPV6_LL="Offline"
fi

clear
echo ""
echo -e "\e[${line}m═══════════════════════════════════════════════${reset}"
echo -e "  \e[${title}[ IP Menu - IPv4 / IPv6 Toggle ]${reset}"
echo -e "\e[${line}m═══════════════════════════════════════════════${reset}"
echo ""
echo -e " IP Address        : ${GREEN}${IPVPS}, ${IPV6}${reset}"
echo -e " IPv6 Link-Local   : ${CYAN}$IPV6_LL${reset}"
echo -e " IPv6 Global       : ${CYAN}$IPV6_GLOBAL${reset}"
echo -e " IPv6 Status       : ${YELLOW}$IPV6_STATUS${reset}"
echo ""
echo " [1]  IPv4 Only (Disable IPv6)"
echo " [2]  IPv4 + IPv6 (Enable IPv6)"
echo " [3]  Reboot Server"
echo ""
echo " [0]  Back to Menu"
echo ""
echo " Notes :"
echo " - Changes require restart to take full effect."
echo ""

read -p " Select menu : " opt
echo ""

case $opt in
1)
    echo "Disabling IPv6..."
    
    # Disable now
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

    # Create rc.local if not exist
    if [ ! -f $RCLOCAL ]; then
#!/bin/bash\nexit 0" > $RCLOCAL
        chmod +x $RCLOCAL
    fi

    # Remove old line if exist
    sed -i '/disable_ipv6/d' $RCLOCAL

    # Insert before exit 0
    sed -i '/exit 0/i echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' $RCLOCAL

    echo "IPv6 disabled and added to rc.local"
    ;;
    
2)
    echo "Enabling IPv6..."

    # Enable now
    echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6

    # Remove from rc.local
    sed -i '/disable_ipv6/d' $RCLOCAL

    echo "IPv6 enabled and removed from rc.local"
    ;;
    
3)
    reboot
    ;;
    
0)
    menu-tweak
    ;;
    
*)
    echo "Wrong selection"
    ;;
esac

echo ""
read -n 1 -s -r -p "Press any key to continue..."
exec /usr/local/bin/ip6menu