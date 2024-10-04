#!/bin/bash

echo "Start preparation"

# Variable modifiable
user="admcld"
userSSHGroup="ssh_users"

# Variables

userPasswd=(openssl rand -hex 20)
cryptUserPasswd=$(perl -e 'print crypt($ARGV[0], "password")' $userPasswd)

osdetected=$true

## Start Script

echo "Starting script"

echo "creation of ssh user : $user"
groupadd $userSSHGroup
useradd -m -G $userSSHGroup -p $cryptUserPasswd 


echo "Dectection OS, packages will be adapt"

. /etc/os-release
    os_name="$NAME"
    os_version="$VERSION"

if [[ $os_name == "Debian*"  -o $os_name == "Ubuntu*" ]]; then

    echo "Debian OS detected, start installation application"

    # Update Packages
    apt update & apt upgrade -y > /dev/null

    # Install openssh for server
    apt install openssh-server fail2ban ufw -y > /dev/null

elif [[ $os_name == "Fedora*" ]]; then

else 
    echo "unrecognize system"
    $osdetected=$false

fi

if [[ $osdetected ]]

    echo "configuration sshd"
    # config ssh connexion
    echo "AllowGroups $userSSHGroup" >> /etc/ssh/sshd_config
    systemctl restart sshd > /dev/null

    echo "Firewall configuratio"
    # Open ssh port with tcp
    ufw allow ssh/tcp > /dev/null
    ufw enable > /dev/null

    echo "Disabling IPv6"
    # Disable IPv6
    echo "# Disabling the IPv6" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    update-initramfs -u > /dev/null

    echo "You server is Ready"
else
    echo "Problem at configuration"

fi
