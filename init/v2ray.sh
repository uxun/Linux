#!/bin/bash
# Centos7 install v2ray Server
read -s -n1 -p "To set the first http proxy(y/n)" sts
#
if [ $sts == n ]; then
  echo -e "\nexport https_proxy=http://USER:PASSWD@IP:PORT;export http_proxy=http://USER:PASSWD@IP:PORT"
exit 0
fi

UPORT="80"
# install v2ray Server
# yum install depends
yum install curl vim -y 

# install v2ray The official
bash <(curl -L -s https://install.direct/go.sh)

systemctl stop firwalld
systemctl disable firewalld

# back default config.json
cp /etc/v2ray/config.json{,.back}
UUID=`/usr/bin/v2ray/v2ctl uuid`
# configuration ws
cat > /etc/v2ray/config.json << EOF
{
  "inbounds": [{
    "port": $UPORT,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$UUID",
          "level": 1,
          "alterId": 64
        }
      ]
    },
    "streamSettings":{
      "wsSettings":{
        "path":"/",
        "headers":{}
    },
    "network":"ws"
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

# start
systemctl start v2ray
systemctl enable v2ray
systemctl status v2ray
