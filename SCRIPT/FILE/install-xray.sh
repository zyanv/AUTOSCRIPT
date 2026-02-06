#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
# V2Ray Mini Core Version 4.42.2
domain=$(cat /etc/xray/domain)
websc=https://raw.githubusercontent.com/zyanv/AUTOSCRIPT/main

apt install python3 -y
apt install cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Kuala_Lumpur
chronyc sourcestats -v
chronyc tracking -v
date


# / / Ambil Xray Core Version Terbaru
#latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"

# / / Installation Xray Core
xraycore_link="${websc}/SCRIPT/XRAY/v25.10.15.3/xray.linux.zip"

# / / Make Main Directory
mkdir -p /usr/bin/xray

# / / Make Main Directory
mkdir -p /usr/local/etc/xray/
touch /usr/local/etc/xray/vless.txt

# Generate certificates
#systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
#service squid start
cd
#systemctl restart nginx
sleep 1
clear

# / / Unzip Xray Linux 64
cd `mktemp -d`
curl -sL "$xraycore_link" -o xray.zip
unzip -q xray.zip && rm -rf xray.zip
mv xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

# Make Folder XRay
mkdir -p /var/log/xray/
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /etc/xray/xray.pid
touch /usr/local/etc/xray/warp-domain.txt

uuid=$(cat /proc/sys/kernel/random/uuid)
uuid2=$(cat /proc/sys/kernel/random/uuid)
cat> /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
       },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "flow": "xtls-rprx-vision",
                        "level": 0
#xray-vless-xtls
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "alpn": "h2",
                        "dest": 1318,
                        "xver": 2
                    },
                    {
                        "dest": 4447,
                        "xver": 2
                    },
                    {
                        "path": "/xvless",
                        "dest": "@vlessws",
                        "xver": 2
                    },
                    {
                        "path": "/xvless-hup",
                        "dest": "@vless-http",
                        "xver": 2
                    }
                            ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "alpn": [
                        "h2",
                        "http/1.1"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/usr/local/etc/xray/xray.crt",
                            "keyFile": "/usr/local/etc/xray/xray.key"
                        }
                    ]
                }
            }
        },
       {
        "port": 1318,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "${uuid}"
#xray-vless-grpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vlgrpc"
                }
            }
        },
       {
            "listen": "@vlessws",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "level": 0
#xray-vless-tls
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "acceptProxyProtocol": true,
                    "path": "/xvless"
                }
            }
        }
],
    "outbounds": [
   {
            "tag": "WARP",
            "protocol": "freedom"
            "proxySettings":{
              "tag":"WARP-socks5"
            },  
            "settings":{
              "domainStrategy":"UseIPv4"
        },
    {
            "tag": "WARP-socks5",
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
                "outboundTag": "default",
                "network": "udp,tcp"
    },
    {
                "type": "field",
                "outboundTag": "blocked",
                "domain": [
                 "playstation.com",
                 "xbox.com"
                 ]
    },
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}

END
cat> /usr/local/etc/xray/none.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
       }, 
        "inbounds": [
    {
            "port": "80",
            "protocol": "vless",
            "settings": {
            "clients": [
                {
                  "id": "${uuid}"
#xray-nontls
                }
            ],
             "fallbacks": [
                 {
                        "path": "/xvlessntls",
                        "dest": "@vlessws",
                        "xver": 2
                 },
                 {
                        "path": "/xvless-hup",
                        "dest": "@vless-http",
                        "xver": 2
                 },
                 {
                        "dest": "@vlessws",
                        "xver": 2
                 }
                         ],
            "decryption": "none"
    },
          "sniffing": {
              "enabled": true,
              "destOverride": [
                 "http",
                 "tls"
             ]
          }
       },
    {
            "listen": "@vlessws-ntls",
            "protocol": "vless",
            "settings": {
            "clients": [
                {
                  "id": "${uuid}"
#xray-vless-nontls
                }
            ],
            "decryption": "none"
         },
         "streamSettings": {
            "network": "ws",
            "security": "none",
            "wsSettings": {
            "path": "/xvlessntls",
            "headers": {
                "Host": ""
               }
            },
            "quicSettings": {}
          },
          "sniffing": {
              "enabled": true,
              "destOverride": [
                 "http",
                 "tls"
             ]
          }
       },
    {
            "listen": "@vless-http",
            "protocol": "vless",
            "settings": {
            "clients": [
                {
                  "id": "${uuid}"
#xray-vless-hup
                }
            ],
            "decryption": "none"
         },
         "streamSettings": {
           "httpupgradeSettings": {
          "acceptProxyProtocol": true,
          "path": "/xvless-hup"
        },
        "network": "httpupgrade",
        "security": "none"
      },
          "sniffing": {
              "enabled": true,
              "destOverride": [
                 "http",
                 "tls",
                 "quic"
             ]
          }
       }
],
    "outbounds": [
   {
            "tag": "default",
            "protocol": "freedom"
        },
    {
            "tag":"socks_out",
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
                "outboundTag": "default",
                "network": "udp,tcp"
    },
    {
                "type": "field",
                "outboundTag": "blocked",
                "domain": [
                 "playstation.com",
                 "xbox.com"
                 ]
    },
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}

END

# starting xray vmess ws tls core on sytem startup
cat> /etc/systemd/system/xray.service << END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

# starting xray vmess ws tls core on sytem startup
cat> /etc/systemd/system/xray@.service << END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

END

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
wget -O vless-list "${websc}/SCRIPT/FILE/user-vless.sh"

chmod +x add-xvless
chmod +x del-xvless
chmod +x renew-xvless
chmod +x cek-xvless
chmod +x recert-xray
chmod +x trial-xvless
chmod +x delexp
chmod +x vless-list
chmod +x user-vless

cd
rm -f install-xray.sh
rm -f /root/domain
clear
echo -e " ${RED}XRAY INSTALL DONE ${NC}"
sleep 2
clear