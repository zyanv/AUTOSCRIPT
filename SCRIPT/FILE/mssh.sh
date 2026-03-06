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

echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " \033[30;5;47m                         ⇱ SSHWS/OVPN MENU ⇲                     \033[m"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${wh}[ 01 ]${NC} ${cy}CREATE NEW USER${NC}            ${wh}[ 06 ]${NC} ${cy}LIST USER INFORMATION${NC}"
echo -e  " ${wh}[ 02 ]${NC} ${cy}CREATE TRIAL USER${NC}          ${wh}[ 07 ]${NC} ${cy}SET AUTO KILL LOGIN${NC}"
echo -e  " ${wh}[ 03 ]${NC} ${cy}EXTEND ACCOUNT ACTIVE${NC}      ${wh}[ 08 ]${NC} ${cy}DISPLAY USER MULTILOGIN${NC}"
echo -e  " ${wh}[ 04 ]${NC} ${cy}DELETE ACTIVE USER${NC}         ${wh}[ 09 ]${NC} ${cy}INSTALL SSHWS${NC}"
echo -e  " ${wh}[ 05 ]${NC} ${cy}CHECK USER LOGIN${NC}"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option : " mssh
echo -e "\e[0m"
 case $mssh in
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
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  mssh
  ;;
  esac
