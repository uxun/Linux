#!/bin/bash
USER=user
PASSWD=""
source /etc/os-release
case $ID in
ubuntu)
    id $USER >& /dev/null
    if [ $? -ne 0 ]
    then
       useradd -m $USER -s /bin/bash
       echo "$USER:$PASSWD" | chpasswd
       echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
       sudo chmod 0644 /etc/sudoers.d/$USER
    else
       echo "$USER:$PASSWD" | chpasswd
       echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
       sudo chmod 0644 /etc/sudoers.d/$USER
    fi
    ;;
centos|rhel)
    id $USER >& /dev/null
    if [ $? -ne 0 ]
    then
       useradd -m $USER
       echo "$PASSWD" | passwd  --stdin $USER
       echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
       sudo chmod 0640 /etc/sudoers.d/$USER
    else
       echo "$PASSWD" | passwd  --stdin $USER
       echo "$USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
       sudo chmod 0640 /etc/sudoers.d/$USER
    fi
    ;;
*)
    exit 1
    ;;
esac
rm -f $0
