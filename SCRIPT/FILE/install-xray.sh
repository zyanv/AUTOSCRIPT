#!/usr/bin/env bash
set -Eeuo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

apt install python3 -y
apt install cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
chronyc sourcestats -v
chronyc tracking -v
date

log() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
die() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Jalankan skrip sebagai root."
export DEBIAN_FRONTEND=noninteractive

DOMAIN_FILE=$(cat /etc/xray/domain)
[[ -s "$DOMAIN_FILE" ]] || DOMAIN_FILE="/etc/xray/domain"
[[ -s "$DOMAIN_FILE" ]] || die "Domain tidak ditemui. Simpan domain di /root/domain atau /etc/xray/domain."
domain="$(tr -d '[:space:]' < "$DOMAIN_FILE")"
[[ -n "$domain" ]] || die "Domain kosong."

# Laluan awam (multipath)
WS_PATH="/xvless"
HUP_PATH="/xvless-hup"
XHTTP_PATH="/xvless-xhttp"

# Port dalaman Xray; hanya boleh dicapai melalui localhost/Nginx
WS_BACKEND=10001
HUP_BACKEND=10002
XHTTP_BACKEND=10003

log "Memasang pakej yang diperlukan"
apt-get update -y
apt-get install -y curl unzip jq nginx cron bash-completion chrony lsof ca-certificates
systemctl enable --now chrony
 timedatectl set-timezone Asia/Kuala_Lumpur

# / / Make Main Directory
mkdir -p /usr/bin/xray

# / / Make Main Directory
mkdir -p /usr/local/etc/xray/
touch /usr/local/etc/xray/vless.txt

log "Memasang sijil TLS Let's Encrypt"
systemctl stop nginx 2>/dev/null || true
pkill -f 'xray run' 2>/dev/null || true
rm -rf /root/.acme.sh
curl -fsSL https://get.acme.sh | sh -s email="admin@${domain}"
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue --standalone -d "$domain" --keylength ec-256
/root/.acme.sh/acme.sh --install-cert -d "$domain" --ecc \
  --fullchain-file /etc/xray/xray.crt \
  --key-file /etc/xray/xray.key \
  --reloadcmd 'systemctl reload nginx || true'
chmod 600 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt

log "Memasang Xray-core versi stabil terkini"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) asset="Xray-linux-64.zip" ;;
  aarch64|arm64) asset="Xray-linux-arm64-v8a.zip" ;;
  *) die "Seni bina tidak disokong secara automatik: $arch" ;;
esac
release_json="$(curl -fsSL https://api.github.com/repos/XTLS/Xray-core/releases/latest)"
download_url="$(jq -r --arg asset "$asset" '.assets[] | select(.name == $asset) | .browser_download_url' <<< "$release_json" | head -n1)"
[[ -n "$download_url" && "$download_url" != "null" ]] || die "URL muat turun Xray tidak ditemui."
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
curl -fL "$download_url" -o "$tmpdir/xray.zip"
unzip -q -o "$tmpdir/xray.zip" -d "$tmpdir/xray"
install -m 0755 "$tmpdir/xray/xray" /usr/local/bin/xray
[[ -f "$tmpdir/xray/geoip.dat" ]] && install -m 0644 "$tmpdir/xray/geoip.dat" /usr/local/share/xray/geoip.dat 2>/dev/null || true
[[ -f "$tmpdir/xray/geosite.dat" ]] && install -m 0644 "$tmpdir/xray/geosite.dat" /usr/local/share/xray/geosite.dat 2>/dev/null || true

uuid="$(cat /proc/sys/kernel/random/uuid)"
uuid2=$(cat /proc/sys/kernel/random/uuid)
echo "$uuid" > /usr/local/etc/xray/uuid
chmod 600 /usr/local/etc/xray/uuid

log "Membina konfigurasi Xray multipath"
cat > /usr/local/etc/xray/config.json <<XRAYJSON
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "vless-ws",
      "listen": "127.0.0.1",
      "port": ${WS_BACKEND},
      "protocol": "vless",
      "settings": {
        "users": [
          {
            "id": "${uuid}",
            "level": 0
            #xray-vless-ws
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "method": "websocket",
        "security": "none",
        "wsSettings": {
          "path": "${WS_PATH}"
        },
        "sockopt": {
          "trustedXForwardedFor": ["X-Real-IP", "X-Forwarded-For"]
        }
      }
    },
    {
      "tag": "vless-httpupgrade",
      "listen": "127.0.0.1",
      "port": ${HUP_BACKEND},
      "protocol": "vless",
      "settings": {
        "users": [
          {
            "id": "${uuid}",
            "level": 0
            #xray-vless-hup
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "method": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "path": "${HUP_PATH}"
        },
        "sockopt": {
          "trustedXForwardedFor": ["X-Real-IP", "X-Forwarded-For"]
        }
      }
    },
    {
      "tag": "vless-xhttp",
      "listen": "127.0.0.1",
      "port": ${XHTTP_BACKEND},
      "protocol": "vless",
      "settings": {
        "users": [
          {
            "id": "${uuid}",
            "level": 0
            #xray-vless-xhttp
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "method": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "path": "${XHTTP_PATH}",
          "mode": "auto"
        },
        "sockopt": {
          "trustedXForwardedFor": ["X-Real-IP", "X-Forwarded-For"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "default",
      "protocol": "freedom"
    },
    {
      "tag": "blocked",
      "protocol": "blackhole"
    },
    {
      "tag": "socks_out",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000
          }
        ]
      }
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "outboundTag": "socks_out",
        "domain": [
          #warp-domain
          "jinggo.com"
        ]
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": ["bittorrent"]
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "ip": [
          "0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10",
          "169.254.0.0/16", "172.16.0.0/12", "192.0.0.0/24",
          "192.0.2.0/24", "192.168.0.0/16", "198.18.0.0/15",
          "198.51.100.0/24", "203.0.113.0/24", "::1/128",
          "fc00::/7", "fe80::/10"
        ]
      }
    ]
  }
}
XRAYJSON

# Xray membenarkan komen JSONC. Ujian konfigurasi dilakukan oleh binary Xray sendiri.
/usr/local/bin/xray run -test -config /usr/local/etc/xray/config.json

log "Membina konfigurasi Nginx untuk TLS 443 dan non-TLS 80/8080"
rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/conf.d/xray-multipath.conf <<NGINX
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${domain};

    ssl_certificate     /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    root /var/www/html;
    index index.html;

    location = ${WS_PATH} {
        proxy_pass http://127.0.0.1:${WS_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location = ${HUP_PATH} {
        proxy_pass http://127.0.0.1:${HUP_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location ^~ ${XHTTP_PATH} {
        client_max_body_size 0;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_pass http://127.0.0.1:${XHTTP_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    listen [::]:80;
    listen 8080;
    listen [::]:8080;
    server_name ${domain} _;

    root /var/www/html;
    index index.html;

    location = ${WS_PATH} {
        proxy_pass http://127.0.0.1:${WS_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location = ${HUP_PATH} {
        proxy_pass http://127.0.0.1:${HUP_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location ^~ ${XHTTP_PATH} {
        client_max_body_size 0;
        proxy_request_buffering off;
        proxy_buffering off;
        proxy_pass http://127.0.0.1:${XHTTP_BACKEND};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1d;
        proxy_send_timeout 1d;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX

cat > /var/www/html/index.html <<HTML
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${domain}</title></head>
<body><h1>Welcome</h1></body></html>
HTML

nginx -t

cat > /etc/systemd/system/xray.service <<'SYSTEMD'
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network-online.target nss-lookup.target
Wants=network-online.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3s
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
SYSTEMD

# Elakkan servis lama berebut port/config.
systemctl disable --now xray@none.service 2>/dev/null || true
systemctl daemon-reload
systemctl enable --now xray nginx
systemctl restart xray nginx

# Simpan maklumat sambungan.
cat > /root/xray-info.txt <<INFO
Domain   : ${domain}
UUID     : ${uuid}

TLS 443:
- WebSocket    : ${WS_PATH}
- HTTP Upgrade : ${HUP_PATH}
- XHTTP        : ${XHTTP_PATH}

Non-TLS 80 dan 8080:
- WebSocket    : ${WS_PATH}
- HTTP Upgrade : ${HUP_PATH}
- XHTTP        : ${XHTTP_PATH}

Backend localhost:
- WS    : 127.0.0.1:${WS_BACKEND}
- HUP   : 127.0.0.1:${HUP_BACKEND}
- XHTTP : 127.0.0.1:${XHTTP_BACKEND}
INFO
chmod 600 /root/xray-info.txt

log "Pemasangan selesai"
echo -e "Domain: ${GREEN}${domain}${NC}"
echo -e "UUID  : ${GREEN}${uuid}${NC}"
echo "Maklumat penuh: /root/xray-info.txt"
echo "Semak servis: systemctl status xray nginx --no-pager"

# enable xray xtls
systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service
systemctl restart xray

# enable xray none
systemctl daemon-reload
systemctl enable xray@none
systemctl start xray@none
systemctl restart xray@none


cd /usr/local/bin
wget -O add-xvless "${websc}/SCRIPT/FILE/add-xvless.sh"
wget -O del-xvless "${websc}/SCRIPT/FILE/del-xvless.sh"
wget -O renew-xvless "${websc}/SCRIPT/FILE/renew-xvless.sh"
wget -O cek-xvless "${websc}/SCRIPT/FILE/cek-xvless.sh"
wget -O recert-xray "${websc}/SCRIPT/FILE/recert-xray.sh"
wget -O trial-xvless "${websc}/SCRIPT/FILE/trial-xvless.sh"
wget -O delexp "${websc}/SCRIPT/FILE/delexp.sh"
wget -O vless-list "${websc}/SCRIPT/FILE/vless-list.sh"


chmod +x add-xvless
chmod +x del-xvless
chmod +x renew-xvless
chmod +x cek-xvless
chmod +x recert-xray
chmod +x trial-xvless
chmod +x delexp
chmod +x vless-list

cd
rm -f install-xray.sh
rm -f /root/domain
clear
echo -e " ${RED}XRAY INSTALL DONE ${NC}"
sleep 2
clear