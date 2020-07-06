#!/bin/bash
#this script is only for CentOS 7.x
#check the OS
#rpm -q centos-release|cut -d- -f3

platform=`uname -i`
if [ $platform != "x86_64" ];then
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
cat << EOF
+---------------------------------------+
|   your system is CentOS 7 x86_64      |
|      start optimizing.......          |
+---------------------------------------
EOF

#添加公网DNS地址
cat >> /etc/resolv.conf << EOF
nameserver 233.5.5.5
nameserver 114.114.114.114
EOF
#Yum源更换为国内阿里源
yum install wget telnet lrzsz net-tools sysstat vim epel-release -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#添加阿里的epel源
#add the epel
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm

#yum重新建立缓存
yum clean all
yum makecache

#同步时间
timedatectl set-timezone Asia/Shanghai
yum -y install ntp
/usr/sbin/ntpdate cn.pool.ntp.org
echo "*/3 * * * * /usr/sbin/ntpdate cn.pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root
systemctl  restart crond.service

#设置最大打开文件描述符数
cat >> /etc/security/limits.conf << EOF
root soft nofile 65535
root hard nofile 65535
* soft nofile 65535
* hard nofile 65535
EOF


#禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

#关闭防火墙
systemctl disable firewalld.service
systemctl stop firewalld.service
service NetworkManager stop
systemctl disable NetworkManager.service
service postfix stop
chkconfig postfix off


#set ssh
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 60025/' /etc/ssh/sshd_config
systemctl  restart sshd.service


#内核参数优化
# cat >> /etc/sysctl.conf << EOF
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1
# net.ipv6.conf.lo.disable_ipv6 = 1
# vm.swappiness = 0
# net.ipv4.neigh.default.gc_stale_time=120
# net.ipv4.conf.all.rp_filter=0
# net.ipv4.conf.default.rp_filter=0
# net.ipv4.conf.default.arp_announce = 2
# net.ipv4.conf.lo.arp_announce=2
# net.ipv4.conf.all.arp_announce=2
# net.ipv4.tcp_max_tw_buckets = 5000
# net.ipv4.tcp_syncookies = 1
# net.ipv4.tcp_max_syn_backlog = 1024
# net.ipv4.tcp_synack_retries = 2
# EOF
# /sbin/sysctl -p


cat << EOF
+-------------------------------------------------+
|               optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
