#!/bin/bash -e

privateBinVersion="1.7.1"

#Installation de PrivateBin sur la machine 
sudo apt install apache2 php -y 
wget https://github.com/PrivateBin/PrivateBin/archive/refs/tags/$privateBinVersion.zip # A mettre à jour pour avoir la dernière version 
cd /var/www/html 
sudo unzip /home/root/$privateBinVersion
sudo mv $privateBinVersion PrivateBin 
sudo chown -R www-data:www-data PrivateBin 
sudo chmod -R g+rw PrivateBin 

 

# Mis à jour de sécurité automatique 

root@privateBin:~# apt install unattended-upgrades -y 

root@privateBin:~# apt install apt-config-auto-update                                 # Disponible sur debian 12 

root@privateBin:~# nano /etc/apt/apt.conf.d/50unattended-upgrades 

root@privateBin:~# dpkg-reconfigure --priority=low unattended-upgrades 

root@privateBin:~# nano /etc/apt/apt.conf.d/20auto-upgrades                 # Vérifier si les valeurs sont bien à 1 