#!/bin/bash
#=========Uxun============#
#=======Centos{6|7}=======#
#==System initialization==#
#=========Uxun============#

#===disable unwanted services ===#
grep -q '7.' /etc/redhat-release
if [ $? -ne 0 ]; then
    Services=$(chkconfig --list | grep '0' | awk '{print $1}' | grep -Ev 'sshd|network|crond|syslog|ntpd')
    for Service in $Services
    do
        service $Service stop
        chkconfig --level 0123456 $Service off
    done
    
else
    Services=(atd avahi-daemon cups dmraid-activation firewalld kdump mdmonitor postfix)
    for Service in ${Services}
    do
        systemctl disable ${Service}
        systemctl stop ${Service}
    done
    systemctl enable rc-local
fi

#==== CentOS Change hostsname ===#
grep -q '7.' /etc/redhat-release
if [ $? -eq 0 ]; then
    read -p "Please name this server: " name
    echo "$name"
    hostnamectl --static set-hostname $name
else
    read -p "Please name this server: " name
    echo "$name"
    cp /etc/sysconfig/network /tmp/
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=$name
EOF
    hostname $name
fi

#==========disable selinux=======#
if [ -f /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi
setenforce 0

#=======Set the time zone= ======#
#=====                      =====#
grep -q '7.' /etc/redhat-release
if [ $? -eq 0 ]; then
    timedatectl set-timezone Asia/Shanghai
else
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi

#=====  Optimization of SSH =====#
sed -i '/UseDNS/s/^.*$/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
grep -q '7.' /etc/redhat-release
if [ $? -eq 0 ]; then
    systemctl restart sshd
else
    service sshd restart
fi

#======  configuration DNS  =====#
echo "nameserver 223.5.5.5 " >> /etc/resolv.conf

#=====    download repo     =====#
if [ `ping 223.6.6.6 -c 5 | grep "min/avg/max" -c` = '1' ]; then
    echo -e "\033[32m Successful! Network connection test successful. \033[0m"
    yum install -y wget vim perl cmake make chrony net-snmp net-snmp-devel net-snmp-utils OpenIPMI openssh-clients net-tools lrzsz
else
    echo -e "\033[31m Failed! Network connection failed, installation aborted! \033[0m"
fi

grep -q '7.' /etc/redhat-release
if [ $? -eq 0 ]; then
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
else
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
fi
yum clean all && yum makecache


#=== File limit optimization  ===#
if cat /etc/security/limits.conf | grep Opt > /dev/null; then
    echo -e "\033[32m limits optimize. \033[0m"
else
    (
cat <<EOF
# Sys Opt
*               soft     nproc         204800
*               hard     nproc         204800

*               soft     nofile        204800
*               hard     nofile        204800
EOF
    ) >> /etc/security/limits.conf
fi


#=Network parameter optimization=#
if cat /etc/sysctl.conf | grep Opt > /dev/null; then
    echo "sysctl.conf 已优化. "
else
    (
cat <<EOF

# Sys Opt

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# kubeadm init
#WARNING: bridge-nf-call-iptables is disabled
#WARNING: bridge-nf-call-ip6tables is disabled
# start modprobe br_netfilter
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 0
net.core.rmem_max = 16777216
net.core.rmem_default = 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 8192000
net.ipv4.tcp_max_tw_buckets = 130000
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_keepalive_time = 120

fs.file-max =165535
net.ipv4.ip_local_port_range = 1024 65535
kernel.panic = 5

# NAT rule 
# start modprobe ip_conntrack
#net.netfilter.nf_conntrack_max = 655350
#net.netfilter.nf_conntrack_tcp_timeout_established = 1200
EOF
    ) >> /etc/sysctl.conf
    
fi

#modprobe ip_conntrack
modprobe br_netfilter
sysctl -p

#ERROR
#sysctl: cannot stat /proc/sys/net/netfilter/nf_conntrack_max: No such file or directory
#modprobe ip_conntrack

#sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables:
#No such file or directory
#sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables:
#No such file or directory

#解决方法：
#modprobe br_netfilter
#ls /proc/sys/net/bridge

#===================Docker-CE yum==============================#
## step 1: 安装必要的一些系统工具
#sudo yum install -y yum-utils device-mapper-persistent-data lvm2
## Step 2: 添加软件源信息
#sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
## Step 3: 更新并安装 Docker-CE
#sudo yum makecache fast
#sudo yum -y install docker-ce
## Step 4: 开启Docker服务
#sudo service docker start

# 注意：
# 官方软件源默认启用了最新的软件，您可以通过编辑软件源的方式获取各个版本的软件包。例如官方并没有将测试版本的软件源置为可用，你可以通过以下方式开启。同理可以开启各种测试版本等。
# vim /etc/yum.repos.d/docker-ce.repo
#   将 [docker-ce-test] 下方的 enabled=0 修改为 enabled=1
#
# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# yum list docker-ce.x86_64 --showduplicates | sort -r
#   Loading mirror speeds from cached hostfile
#   Loaded plugins: branch, fastestmirror, langpacks
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            @docker-ce-stable
#   docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
#   Available Packages
# Step2 : 安装指定版本的Docker-CE: (VERSION 例如上面的 17.03.0.ce.1-1.el7.centos)
# sudo yum -y install docker-ce-[VERSION]

#===================Kubernetes epel(国内aliyun镜像)==============================#
#CentOS / RHEL / Fedora
#cat <<EOF > /etc/yum.repos.d/kubernetes.repo
#[kubernetes]
#name=Kubernetes
#baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
#enabled=1
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
#yum install -y kubelet kubeadm kubectl
#systemctl enable kubelet && systemctl start kubelet


