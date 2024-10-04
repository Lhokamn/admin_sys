#!/bin/bash

echo "Start preparation"

# Variable modifiable
user="admcld"
userSSHGroup="ssh_users"

# Variables

userPasswd=(openssl rand -hex 20)
cryptUserPasswd=$(perl -e 'print crypt($ARGV[0], "password")' $userPasswd)

## Start Script

echo "Starting script"

echo "creation of ssh user : $user"
groupadd $userSSHGroup
useradd -m -G $userSSHGroup -p $cryptUserPasswd 


echo "Dectection OS, packages will be adapt"

. /etc/os-release
    os_name="$NAME"
    os_version="$VERSION"

if [[ $system == "Debian*" ]]; then

    # Update Packages
    apt update & apt upgrade -y > /dev/null

    # Install openssh for server
    apt install openssh-server fail2ban ufw -y > /dev/null

elif [[ $system == "" ]]; then

else 
    echo "unrecognize system"

fi

echo "Fin de l'installation des packages"

# config ssh connexion
cp ssh/sshd_config /etc/ssh/sshd_config
echo "AllowGroups $userSSHGroup" >> /etc/ssh/sshd_config
systemctl restart sshd

# Open ssh port with tcp
ufw allow ssh/tcp
ufw enable

# Disable IPv6
echo "# Disabling the IPv6" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
update-initramfs -u
