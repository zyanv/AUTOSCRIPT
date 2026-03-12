#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
#########################

BURIQ() {
  curl -sS https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/allow >/root/tmp
  data=($(cat /root/tmp | grep -E "^### " | awk '{print $2}'))
  for user in "${data[@]}"; do
    exp=($(grep -E "^### $user" "/root/tmp" | awk '{print $3}'))
    d1=($(date -d "$exp" +%s))
    d2=($(date -d "$biji" +%s))
    exp2=$(((d1 - d2) / 86400))
    if [[ "$exp2" -le "0" ]]; then
      echo $user >/etc/.$user.ini
    else
      rm -f /etc/.$user.ini >/dev/null 2>&1
    fi
  done
  rm -f /root/tmp
}

MYIP=$(curl -sS ipv4.icanhazip.com)
Name=$(curl -sS https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/allow | grep $MYIP | awk '{print $2}')
echo $Name >/usr/local/etc/.$Name.ini
CekOne=$(cat /usr/local/etc/.$Name.ini)

Bloman() {
  if [ -f "/etc/.$Name.ini" ]; then
    CekTwo=$(cat /etc/.$Name.ini)
    if [ "$CekOne" = "$CekTwo" ]; then
      res="Expired"
    fi
  else
    res="Permission Accepted..."
  fi
}

PERMISSION() {
  MYIP=$(curl -sS ipv4.icanhazip.com)
  IZIN=$(curl -sS https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/allow | awk '{print $4}' | grep $MYIP)
  if [ "$MYIP" = "$IZIN" ]; then
    Bloman
  else
    res="Permission Denied!"
  fi
  BURIQ
}
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
PERMISSION

if [ "$res" = "Permission Accepted..." ]; then
  echo -ne
else
  red "Permission Denied!"
  exit 0
fi
clear

encryptReqv1() {
  echo -e "\033[0;34mPLEASE INPUT YOUR TARGET PATH\033[0m"
  echo -e "\033[0;34mIF USE DEFAULT PATH , JUST CLICK ENTER\033[0m"
  echo ""
  echo -ne "DIRECTORY [default: \E[44;1;39m/root/samenc\E[0m] : "
  read dir
  [[ -z $dir ]] && dir="/root/samenc"
  ls -d $dir/*/ >/root/samdir
  ls -d $dir/*/*/ >>/root/samdir
  a=$(cat /root/samdir)
  for b in $a; do
    ls $b*.sh >>/root/samdirfile
    clear
  done
  ls $dir/*.sh >/root/samencfile
  auto=$(cat /root/samencfile)
  encdir=$(cat /root/samdirfile)
  for encc in $encdir; do
    shc -r -f $encc
  done
  for nama in $auto; do
    shc -r -f $nama
    cd $dir
    for file in *.sh.x; do
      mv "$file" "${file/.sh.x/.sh}"
    done
  done
  for clear in $a; do
    rm -f $clear*.c
    for fidir in $clear*.x; do
      mv "$fidir" "${fidir/.sh.x/.sh}"
    done
  done
  rm -f /$dir/*.c
  rm -f /root/samdir
  rm -f /root/samencfile
  rm -f /root/samdirfile
  clear
  echo -e '\e[0;32mDONE ENCRYPT\033[0m'
  echo -e ''
  echo -e "YOUR ENCRYPTED FILE PATH : $dir"
  read -n 1 -s -r -p "Press any key to back on menu"

  enc
}

encryptReqv2() {
  echo -e "\033[0;34mPLEASE INPUT YOUR TARGET PATH\033[0m"
  echo -e "\033[0;34mIF USE DEFAULT PATH , JUST CLICK ENTER\033[0m"
  echo ""
  echo -ne "DIRECTORY [default: \E[44;1;39m/root/samenc\E[0m] : "
  read dir
  [[ -z $dir ]] && dir="/root/samenc"
  ls -d $dir/*/ >/root/samdir
  ls -d $dir/*/*/ >>/root/samdir
  a=$(cat /root/samdir)
  for b in $a; do
    ls $b*.sh >>/root/samdirfile
    clear
  done
  ls $dir/*.sh >/root/samencfile
  auto=$(cat /root/samencfile)
  encdir=$(cat /root/samdirfile)
  for encc in $encdir; do
    shc -r -v -f $encc
  done
  for nama in $auto; do
    shc -r -v -f $nama
    cd $dir
    for file in *.sh.x; do
      mv "$file" "${file/.sh.x/.sh}"
    done
  done
  for clear in $a; do
    rm -f $clear*.c
    for fidir in $clear*.x; do
      mv "$fidir" "${fidir/.sh.x/.sh}"
    done
  done
  rm -f /$dir/*.c
  rm -f /root/samdir
  rm -f /root/samencfile
  rm -f /root/samdirfile
  clear
  echo -e '\e[0;32mDONE ENCRYPT\033[0m'
  echo -e ''
  echo -e "YOUR ENCRYPTED FILE PATH : $dir"
  read -n 1 -s -r -p "Press any key to back on menu"

  enc
}

MYIP=$(curl -sS ipv4.icanhazip.com)
client=$(curl -sS https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/allow | grep $MYIP | awk '{print $2}')
exp=$(curl -sS https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main/SCRIPT/FILE/allow | grep $MYIP | awk '{print $3}')
yell='\e[1;33m'
NC='\e[0m'
if [ ! -f /usr/bin/zip ]; then
  apt install zip -y &>/dev/null
  apt install git -y &>/dev/null
fi
if [ ! -d /root/samenc ]; then
  mkdir /root/samenc
else
  echo -ne "[ ${yell}WARNING${NC} ] Do you want to Clear Encrypt Folder ? (y/n)? "
  read answer
  if [ "$answer" == "${answer#[Yy]}" ]; then
    echo ""
  else
    rm -rf /root/samenc/*
  fi
fi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m                ⇱ ENCRYPT MENU ⇲                  \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e "[\033[0;32m01\033[0m] • ENCRYPT V1        [\033[0;32m02\033[0m] • ENCRYPT V2"
echo -e ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Client Name   : $client"
echo -e "Expiry script : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -ne "Select menu : "
read x

case "$x" in
1 | 01)
  clear
  encryptReqv1
  ;;
2 | 02)
  clear
  encryptReqv2
  ;;
*)
  clear
  enc
  ;;
esac
