#!/bin/bash

echo "Start preparation"

#System detection for command
system=$OSTYPE

if [[ $system == "debian" -o  $system == "Ubuntu*" ]]; then

    echo "Who is going to use ssh ?"
    read userssh

    # Update Packages
    apt update & apt upgrade -y

    # Install openssh for server
    apt install openssh-server -y

    # config ssh connexion
    cp ssh/sshd_config /etc/ssh/sshd_config
    echo "AllowUsers $userssh" >> /etc/ssh/sshd_config
    systemctl restart ssh

    # Install fail2ban
    apt install fail2ban -y
    cp ssh/jail.local /etc/fail2ban/jail.local
    systemctl restart fail2ban

    # Install ufw firewall
    apt install ufw -y

    # Open ssh port with tcp
    ufw allow ssh/tcp
    ufw enable

    # Disable IPv6
    # Désactiver IPv6
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf


    echo "Everything is update !"
else 
    echo "unrecognize system"

fi

