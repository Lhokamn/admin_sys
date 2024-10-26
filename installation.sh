#!/bin/bash

echo "Start preparation"

# Variable modifiable
user="admcld"
userSSHGroup="ssh_users"

## Start Script

echo "Starting script"

echo "creation of ssh user : $user"
groupadd $userSSHGroup
userPasswd=(openssl rand -hex 20)
cryptUserPasswd=$(perl -e 'print crypt($ARGV[0], "password")' $userPasswd)
useradd -m -G $userSSHGroup -p $cryptUserPasswd 


echo "Dectection OS, packages will be adapt"

# By default, os_detected is at true because he don't have to change it at any os, we change it only if os was not detected
osdetected=$true

. /etc/os-release
    os_name="$NAME"
    os_version="$VERSION"

if [[ $os_name == "Debian*"  -o $os_name == "Ubuntu*" ]]; then
# Variable modifiable
user="admcld"
userSSHGroup="ssh_users"

## Start Script

echo "Starting script"

echo "creation of ssh user : $user"
groupadd $userSSHGroup
userPasswd=(openssl rand -hex 20)
cryptUserPasswd=$(perl -e 'print crypt($ARGV[0], "password")' $userPasswd)
useradd -m -G $userSSHGroup -p $cryptUserPasswd 


echo "Dectection OS, packages will be adapt"

# By default, os_detected is at true because he don't have to change it at any os, we change it only if os was not detected
osdetected=$true

. /etc/os-release
    os_name="$NAME"
    os_version="$VERSION"

if [[ $os_name == "Debian*"  -o $os_name == "Ubuntu*" ]]; then

    echo "Debian OS detected, start installation application"
    echo "Debian OS detected, start installation application"

    # Update Packages
    apt update & apt upgrade -y > /dev/null
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
    apt install openssh-server fail2ban ufw -y > /dev/null

elif [[ $os_name == "Fedora*" ]]; then

else 
    echo "unrecognize system"
    $osdetected=$false

fi

if [[ $osdetected ]]

    echo "configuration sshd"
    # config ssh connexion
    # awk '{gsub(/PermitRootLogin yes/, "PermitRootLogin no"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config  # Remplacement de la valeur
    # awk '{gsub(/#MaxAuthTries 6/, "MaxAuthTries 3"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config          # Remplacement de la valeur
    # awk '{gsub(/#MaxSessions 10/, "MaxSessions 3"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config           # Remplacement de la valeur
    echo "AllowGroups $userSSHGroup" >> /etc/ssh/sshd_config
    systemctl restart sshd > /dev/null

    echo "Firewall configuration"
    # awk '{gsub(/PermitRootLogin yes/, "PermitRootLogin no"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config  # Remplacement de la valeur
    # awk '{gsub(/#MaxAuthTries 6/, "MaxAuthTries 3"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config          # Remplacement de la valeur
    # awk '{gsub(/#MaxSessions 10/, "MaxSessions 3"); print}' /etc/ssh/sshd_config > /etc/ssh/sshd_config           # Remplacement de la valeur
    echo "AllowGroups $userSSHGroup" >> /etc/ssh/sshd_config
    systemctl restart sshd > /dev/null

    echo "Firewall configuration"
    # Open ssh port with tcp
    ufw allow ssh/tcp > /dev/null
    ufw enable > /dev/null

    echo "fail2ban configuration"
    wget -P /etc/fail2ban/ https://doc.cclaudel.fr/configurations/ssh/jail.local

    echo "Disabling IPv6"
    ufw allow ssh/tcp > /dev/null
    ufw enable > /dev/null

    echo "fail2ban configuration"
    wget -P /etc/fail2ban/ https://doc.cclaudel.fr/ssh/jail.local

    echo "Disabling IPv6"
    # Disable IPv6
    echo "# Disabling the IPv6" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    update-initramfs -u > /dev/null
    update-initramfs -u > /dev/null

    echo "You server is Ready"
else
    echo "Problem at configuration"

fi
