#!/bin/bash
# install polipo
# install depend
yum install texinfo gcc git -y

# mk dir
mkdir /etc/polipo
# git clone
git clone https://github.com/jech/polipo.git /opt/polipo
cd /opt/polipo &&  make all && make install

# configuration polipo
cp /opt/polipo/config.sample /etc/polipo/config

cat > /usr/lib/systemd/system/polipo.service << EOF
[Unit]
Description=polipo web proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/polipo -c /etc/polipo/config
Restart=always
SyslogIdentifier=Polipo

[Install]
WantedBy=multi-user.target
EOF

cat >> /etc/polipo/config << EOF
logSyslog = true
logFile = /var/log/polipo.log
pidFile = /var/run/polipo.pid
proxyAddress = "0.0.0.0"
proxyPort = 8123
proxyAddress = "0.0.0.0"
authCredentials = pig:pig123456
EOF

# start
systemctl start polipo
systemctl enable polipo
systemctl status polipo
