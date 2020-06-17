#!/bin/bash

# https://developer.aliyun.com/mirror/
# refernece https://getsubstrate.io
# OS install ansible 
# uxun
# Tip:
# Using the root user to execute the script

source /etc/os-release
case $ID in
debian|ubuntu|devuan)
    if [ $NAME == "Ubuntu" ];then
        apt update
        apt install software-properties-common -y
        apt-add-repository --yes --update ppa:ansible/ansible -y
        apt install ansible -y
    else
		echo "Unknown Linux distribution."
		echo "This OS is not supported with this script at present. Sorry."
    fi
    ;;
centos|rhel)
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
    mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
    if [ $VERSION_ID == 6 ];then
        curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-6.repo
        yum makecache
        yum install -y ansible git python python-pip expect
    	cp /etc/ansible/ansible.cfg{,.back} && cp /etc/ansible/hosts{,.back}
	    curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/uxun/playbook/master/ansible.cfg
   		curl -o /etc/ansible/hosts https://raw.githubusercontent.com/uxun/playbook/master/examples/hosts
    elif [ $VERSION_ID == 7 ];then
		curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
        yum makecache
        yum install -y ansible git python python-pip expect
        cp /etc/ansible/ansible.cfg{,.back} && cp /etc/ansible/hosts{,.back}
        curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/uxun/playbook/master/ansible.cfg
        curl -o /etc/ansible/hosts https://raw.githubusercontent.com/uxun/playbook/master/examples/hosts
    elif [ $VERSION_ID == 8 ];then
        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo
        yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
        sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
		sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*
        yum makecache
        yum install -y ansible git expect 
        cp /etc/ansible/ansible.cfg{,.back} && cp /etc/ansible/hosts{,.back}
        curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/uxun/playbook/master/ansible.cfg
        curl -o /etc/ansible/hosts https://raw.githubusercontent.com/uxun/playbook/master/examples/hosts
    else 
		echo "Unknown Linux distribution."
		echo "This OS is not supported with this script at present. Sorry."
    fi
    ;;
*)
    exit 1
    ;;
esac
