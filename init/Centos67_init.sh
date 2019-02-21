#!/bin/sh

#---------------------------------------#
# description: centos6/7系统优化脚本 #

# author: Jason #

#---------------------------------------#

# 基础服务优化

grep -q '7.' /etc/redhat-release

if [ $? -ne 0 ]; then

Services=$(chkconfig --list | grep '0' | awk '{print $1}' | grep -Ev 'sshd|network|crond|syslog|ntpd')

for Service in $Services

do

service $Service stop

chkconfig --level 0123456 $Service off

done

else

Services=(atd avahi-daemon cups dmraid-activation firewalld irqbalance kdump mdmonitor postfix)

for Service in ${Services

}

do

systemctl disable ${Service}

systemctl stop ${Service}

done

systemctl enable rc-local

fi

# 内核参数调优

grep -q "net.ipv4.tcp_max_tw_buckets" /etc/sysctl.conf || cat >> /etc/sysctl.conf << EOF

#######################################

net.core.rmem_default = 262144

net.core.rmem_max = 16777216

net.core.wmem_default = 262144

net.core.wmem_max = 16777216

net.core.somaxconn = 262144

net.core.netdev_max_backlog = 262144

net.ipv4.tcp_max_orphans = 262144

net.ipv4.tcp_max_syn_backlog = 262144

net.ipv4.tcp_max_tw_buckets = 10000

net.ipv4.ip_local_port_range = 1024 65500

net.ipv4.tcp_tw_recycle = 1

net.ipv4.tcp_tw_reuse = 1

net.ipv4.tcp_syncookies = 1

net.ipv4.tcp_synack_retries = 1

net.ipv4.tcp_syn_retries = 1

net.ipv4.tcp_fin_timeout = 30

net.ipv4.tcp_keepalive_time = 1200

net.ipv4.tcp_mem = 786432 1048576 1572864

fs.aio-max-nr = 1048576

fs.file-max = 6815744

kernel.sem = 250 32000 100 10000

kernel.pid_max = 65536

fs.inotify.max_user_watches = 1048576

kernel.kptr_restrict = 1

kernel.ctrl-alt-del = 1

vm.swappiness = 0

vm.overcommit_memory = 1

EOF

sysctl -p

#提高系统打开文件数、打开进程数限制，减小默认栈空间大小限制

grep -q "* soft nofile 60000" /etc/security/limits.conf || cat >> /etc/security/limits.conf << EOF

########################################

* soft nofile 60000

* hard nofile 65536

* soft nproc 2048

* hard nproc 16384

* soft stack 10240

* hard stack 32768

EOF

#提高Shell打开文件数、打开进程数限制，减小默认栈空间大小限制

grep -q "ulimit -Sn 60000" /etc/profile || cat >> /etc/profile << EOF

########################################

ulimit -Sn 60000

ulimit -Hn 65536

ulimit -Su 2048

ulimit -Hu 16384

ulimit -Ss 10240

ulimit -Hs 32768

alias grep='grep --color=auto'

export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

EOF

# 禁用并关闭selinux

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

setenforce 0

# 优化SSH

sed -i 's/.*UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

sed -i 's/.*GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config

grep -q '7.' /etc/redhat-release

if [ $? -ne 0 ]; then

/etc/init.d/sshd restart

else

systemctl restart sshd

fi

# 安装基础应用

yum -y --skip-broken install ntpdate screen wget rsync curl gcc vim-enhanced xz iftop sysstat dstat htop iotop lrzsz net-tools bash-completion

# 换repo源

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

wget http://mirrors.aliyun.com/repo/epel.repo -O /etc/yum.repos.d/epel.repo

grep -q '7.' /etc/redhat-release

if [ $? -ne 0 ]; then

wget http://mirrors.aliyun.com/repo/Centos-6.repo -O /etc/yum.repos.d/CentOS-Base.repo

else

wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/CentOS-Base.repo

fi

# 安装插件

#yum -y install python-simplejson libselinux-python

# 设置时间服务器

cat > /var/spool/cron/root << EOF

0 * * * * /usr/sbin/ntpdate time.windows.com &> /dev/null

#ntpdate time.windows.com &> /dev/null

EOF
