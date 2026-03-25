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

echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " \033[30;5;47m                         ⇱ XRAY MENU ⇲                           \033[m"       
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} " 
echo -e  " ${wh}[ 01 ]${NC} ${cy}CREATE NEW USER${NC}            ${wh}[ 06 ]${NC} ${cy}CHECK USER LOGIN${NC}"
echo -e  " ${wh}[ 02 ]${NC} ${cy}CREATE TRIAL USER${NC}          ${wh}[ 07 ]${NC} ${cy}LIST USER${NC}"
echo -e  " ${wh}[ 03 ]${NC} ${cy}EXTEND ACCOUNT ACTIVE${NC}      ${wh}[ 08 ]${NC} ${cy}RENEW XRAY CERTIFICATION${NC}"
echo -e  " ${wh}[ 04 ]${NC} ${cy}DELETE ACTIVE USER${NC}         ${wh}[ 09 ]${NC} ${cy}IPV4/IPV6${NC}  "
echo -e  " ${wh}[ 05 ]${NC} ${cy}CHECK CONFIG USER${NC}"
echo -e  " ${cy}═════════════════════════════════════════════════════════════════${NC} "
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option : " mray
echo -e "\e[0m"
 case $mray in
 1)
  clear ; add-xvless
  ;;
  2)
  clear ; trial-xvless
  ;;
  3)
  clear ; renew-xvless
  ;;
  4)
  clear ; del-xvless
  ;;
  5)
  clear ; config-vless
  ;; 
  6)
  clear ; cek-xvless
  ;;
  7)
  clear ; vless-list
  ;;
  8)
  clear ; recert-xray
  ;;
  9)
  clear ; ip6menu
  ;;
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  mray
  ;;
  esac
