#!/bin/bash

# ==========================================
# GLOBAL COLORS & VARIABLES
# ==========================================
RCLOCAL="/etc/rc.local"

# Standard Colors
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[1;33m'
BLUE='\e[0;34m'
CYAN='\e[1;36m'
MAGENTA='\e[0;35m'
PINK='\e[38;5;205m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color / Reset

# Theme Colors
LINE_COLOR="\e[38;5;208m" # Orange terang
TITLE_BG="\e[30;107m"     # Hitam dengan background putih

    echo ""
    echo -e "${LINE_COLOR}═══════════════════════════════════════════════${NC}"
    echo -e "  ${TITLE_BG}[ IP Menu - IPv4 / IPv6 Toggle ]${NC}"
    echo -e "${LINE_COLOR}═══════════════════════════════════════════════${NC}"
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
            echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

            if [ ! -f $RCLOCAL ]; then
                # FIX: Added missing echo command here
                echo -e "#!/bin/bash\nexit 0" > $RCLOCAL
                chmod +x $RCLOCAL
            fi

            sed -i '/disable_ipv6/d' $RCLOCAL
            sed -i '/exit 0/i echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' $RCLOCAL

            echo "IPv6 disabled and added to rc.local"
            ;;
        2)
            echo "Enabling IPv6..."
            echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6
            sed -i '/disable_ipv6/d' $RCLOCAL
            echo "IPv6 enabled and removed from rc.local"
            ;;
        3)
            reboot
            ;;
        0)
            menu-tweak
            return
            ;;
        *)
            echo "Wrong selection"
            ;;
    esac
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
    menu-tweak
