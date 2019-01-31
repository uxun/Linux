#!/bin/bash
#=========shixun============
# 2018-03-09#

#update hostsname
#CentOS 7 
#read -p "Please name this server: " name
#echo "$name"
#hostnamectl --static set-hostname $name

#sysctl: cannot stat /proc/sys/net/netfilter/nf_conntrack_max: No such file or directory
modprobe ip_conntrack

# 设置时区
timedatectl list-timezones
timedatectl set-timezone Asia/Shanghai

#关闭selinux
if [ -f /etc/selinux/config ]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi
setenforce 0
#============关闭firewalld服务
systemctl stop firewalld.service     
systemctl disable firewalld.service
#============配置DNS
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
#============配置yum源 (gcc 无安装)
if [ `ping www.163.com -c 5 | grep "min/avg/max" -c` = '1' ]; then
        echo "网络连接测试成功."
        yum install -y wget vim perl cmake make chrony net-snmp net-snmp-devel net-snmp-utils OpenIPMI openssh-clients net-tools lrzsz 
        else
        echo "网络连接失败, 安装终止!"
fi
#Base.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#epel.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#重载
yum clean all && yum makecache


# ==================网络参数优化==================#
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

net.netfilter.nf_conntrack_max = 655350
net.netfilter.nf_conntrack_tcp_timeout_established = 1200
EOF
) >> /etc/sysctl.conf

fi

modprobe ip_conntrack
sysctl -p

#================= 文件限制优化 ==========================#
if cat /etc/security/limits.conf | grep Opt > /dev/null; then
        echo "limits.conf 已优化. "
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


#================k8s=================#
#关闭swapoff （docker 1.8 以上）
swapoff -a 
sed 's/.*swap.*/#&/' /etc/fstab

#设置内核
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -p /etc/sysctl.conf

	#若问题
	#执行sysctl -p 时出现：
	#sysctl -p
	#sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: 
	#No such file or directory
	#sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: 
	#No such file or directory
	#解决方法：
	#modprobe br_netfilter
	#ls /proc/sys/net/bridge

# 禁用无关服务
systemctl disable wpa_supplicant.service
systemctl disable postfix.service
systemctl disable tuned.service
systemctl disable NetworkManager.service

# 停止无关服务
systemctl stop wpa_supplicant.service
systemctl stop postfix.service
systemctl stop tuned.service
systemctl stop NetworkManager.service

# 加快SSH登陆验证
sed -i '/UseDNS/s/^.*$/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd 

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


