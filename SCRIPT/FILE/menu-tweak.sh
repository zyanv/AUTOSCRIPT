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

# ==========================================
# FUNCTION: IPv4 / IPv6 Toggle
# ==========================================
ip6menu() {
    clear
    IPVPS=$(curl -s ipv4.icanhazip.com || curl -s ipinfo.io/ip || curl -s ifconfig.me)
    IPV6=$(curl -s -6 ipv6.icanhazip.com)

    if [ -z "$IPV6" ]; then
        IPV6="${GREEN}(IPv4 only)${NC}"
    else
        IPV6="${GREEN}($IPV6)${NC}"
    fi

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

    echo ""
    echo -e "${LINE_COLOR}═══════════════════════════════════════════════${NC}"
    echo -e "  ${TITLE_BG}[ IP Menu - IPv4 / IPv6 Toggle ]${NC}"
    echo -e "${LINE_COLOR}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e " IP Address        : ${GREEN}${IPVPS}, ${IPV6}${NC}"
    echo -e " IPv6 Link-Local   : ${CYAN}$IPV6_LL${NC}"
    echo -e " IPv6 Global       : ${CYAN}$IPV6_GLOBAL${NC}"
    echo -e " IPv6 Status       : ${YELLOW}$IPV6_STATUS${NC}"
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
}

# ==========================================
# FUNCTION: Swap RAM Manager
# ==========================================
showswap() {
    curr_swap=$(grep -w "/swapfile" /proc/swaps | awk '{print $3}')
    curr_swap_mb=$((curr_swap / 1024))

    if [ "$curr_swap_mb" -gt 0 ]; then
        swap_status="${GREEN}Active${NC}"
    else
        swap_status="${RED}Not Active${NC}"
    fi

    echo -e "${WHITE}Current Swap : ${GREEN}${curr_swap_mb} MB${NC} (${swap_status})"
    echo ""
}

swapram2() {
    clear
    echo -e "${LINE_COLOR}═══════════════════════════════════${NC}"
    echo -e "  ${TITLE_BG}[ CUSTOM SWAP-RAM ]${NC}"
    echo -e "${LINE_COLOR}═══════════════════════════════════${NC}"
    echo -e "${WHITE}SwapRAM By NevermoreSSH${NC}"
    echo -e "${WHITE}Telegram : https://t.me/Rerechan02${NC}"
    echo -e ""

    showswap

    echo -e " [${CYAN}•1${NC}]  Add 512MB RAM"
    echo -e " [${CYAN}•2${NC}]  Add 768MB RAM"
    echo -e " [${CYAN}•3${NC}]  Add 1GB RAM"
    echo -e " [${CYAN}•4${NC}]  Add 2GB RAM"
    echo -e " [${CYAN}•5${NC}]  Add 4GB RAM"
    echo -e " [${CYAN}•6${NC}]  Disable Swap RAM"
    echo -e ""
    echo -e " [${CYAN}•0${NC}]  Back to menu"
    echo ""
    echo -e "${WHITE}Press [ Ctrl+C ] • To-Exit-Script${NC}"
    echo ""
    read -p "Select From Options [ 1 - 6 ] :  " swap1
    echo -e ""

    case $swap1 in
        1|2|3|4|5)
            clear
            echo -e "[ ${GREEN}INFO${NC} ] Disabling old swap..."
            swapoff --all
            rm -f /swapfile
            
            case $swap1 in
                1) swap_size=524288; swap_name="512MB" ;;
                2) swap_size=786432; swap_name="768MB" ;;
                3) swap_size=1048576; swap_name="1GB" ;;
                4) swap_size=2097152; swap_name="2GB" ;;
                5) swap_size=4194304; swap_name="4GB" ;;
            esac

            echo -e "[ ${GREEN}INFO${NC} ] Creating new ${swap_name} swap..."
            dd if=/dev/zero of=/swapfile bs=1024 count=$swap_size
            mkswap /swapfile
            chmod 600 /swapfile
            swapon /swapfile
            sed -i '/\/swapfile/d' /etc/fstab
            echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
            sleep 2
            swapram2
            ;;
        6)
            clear
            echo -e "[ ${GREEN}INFO${NC} ] Disabling Swap..."
            swapoff --all
            rm -f /swapfile
            sed -i '/\/swapfile/d' /etc/fstab
            echo -e "[ ${GREEN}INFO${NC} ] Swap Disabled!"
            sleep 2
            swapram2
            ;;
        0|x)
            menu-tweak
            ;;
        *)
            clear
            echo -e "[ ${RED}ERROR${NC} ] Invalid Option!"
            sleep 2
            swapram2
            ;;
    esac
}

# ==========================================
# FUNCTION: BBR Manager
# ==========================================
Add_Line_If_Not_Exist() {
    if [ "$(tail -n1 "$1" | wc -l)" == "0" ]; then
        echo "" >> "$1"
    fi
    echo "$2" >> "$1"
}

Check_And_Add_Line() {
    if [ -z "$(grep -Fx "$2" "$1")" ]; then
        Add_Line_If_Not_Exist "$1" "$2"
    fi
}

check_status() {
    cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    if [[ "$cc" == "bbr" ]]; then
        echo -e "${BLUE}Current congestion control: ${YELLOW}$cc${NC} (${GREEN}BBR ON${NC})"
    else
        echo -e "${BLUE}Current congestion control: ${YELLOW}$cc${NC} (${RED}BBR OFF${NC})"
    fi
}

enable_bbr() {
    echo -e "${GREEN}Enabling BBR...${NC}"
    modprobe tcp_bbr
    Add_Line_If_Not_Exist "/etc/modules-load.d/modules.conf" "tcp_bbr"
    sed -i '/net.ipv4.tcp_congestion_control\s*=\s*cubic/d' /etc/sysctl.conf
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
    sysctl -p
    if lsmod | grep -q tcp_bbr && sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo -e "${GREEN}BBR successfully enabled!${NC}"
    else
        echo -e "${RED}Failed to enable BBR!${NC}"
    fi
    check_status
}

disable_bbr() {
    echo -e "${RED}Disabling BBR (switching to cubic)...${NC}"
    sed -i '/net.ipv4.tcp_congestion_control\s*=\s*bbr/d' /etc/sysctl.conf
    sysctl -w net.ipv4.tcp_congestion_control=cubic
    sysctl -p
    echo -e "${RED}BBR is now disabled, using cubic.${NC}"
    check_status
}

optimize_parameters() {
    echo -e "${BLUE}Optimizing system parameters...${NC}"
    Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"
    Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"
    sysctl -p
    echo -e "${GREEN}System optimization completed.${NC}"
}

bbr_manager() {
    clear
    echo -e "${LINE_COLOR}═══════════════════════════════════════════${NC}"
    echo -e "  ${TITLE_BG}[ BBR Manager + Optimizer ]${NC}"
    echo -e "${LINE_COLOR}═══════════════════════════════════════════${NC}"
    echo -e "${WHITE}BBR Manager By NevermoreSSH${NC}"
    echo -e "${WHITE}Telegram : https://t.me/todfix667${NC}"
    echo -e " "
    check_status
    echo -e " "
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "${WHITE}1) Enable BBR${NC}"
    echo -e "${WHITE}2) Disable BBR${NC}"
    echo -e "${WHITE}3) Optimize system parameters${NC}"
    echo -e "${WHITE}4) Check BBR status${NC}"
    echo -e " "
    echo -e "${RED}0) Back to menu${NC}"
    read -p "Enter choice [0-4]: " choice

    case $choice in
        1) enable_bbr; sleep 2; bbr_manager ;;
        2) disable_bbr; sleep 2; bbr_manager ;;
        3) optimize_parameters; sleep 2; bbr_manager ;;
        4) check_status; sleep 2; bbr_manager ;;
        0|x) menu-tweak ;;
        *) echo -e "${RED}Invalid choice!${NC}"; sleep 1; bbr_manager ;;
    esac
}

# ==========================================
# MAIN TWEAK MENU
# ==========================================
menu-tweak() {
    clear
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "  ${WHITE}[ TWEAK MENU SYSTEM OPTIMIZATION ]${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${WHITE}System Tweaks by Rerechan02${NC}"
    echo -e "${WHITE}Telegram : https://t.me/Rerechan02${NC}"
    echo ""
    echo -e " [${CYAN}•1${NC}]  IPv4v6 Toggle"
    echo -e " [${CYAN}•2${NC}]  Swap RAM Manager"
    echo -e " [${CYAN}•3${NC}]  BBR Manager"
    echo ""
    echo -e " [${CYAN}•0${NC}]  Back To Main Menu"
    echo ""
    echo -e "${WHITE}Press [ Ctrl+C ] • To Exit Script${NC}"
    echo ""
    read -p " Select menu : " opt
    echo ""
    
    case $opt in
        1) ip6menu ;;
        2) swapram2 ;;
        3) bbr_manager ;;
        0|x) 
            # Pastikan fungsi 'menu' ada di script utama kamu
            if command -v menu &> /dev/null; then
                menu
            else
                echo -e "${RED}Returning to shell...${NC}"
                exit 0
            fi
            ;;
        *) 
            echo "Wrong Button"
            sleep 1
            menu-tweak 
            ;;
    esac
}

# Execute the main menu
menu-tweak