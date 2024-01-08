#Installation de PrivateBin sur la machine 

root@privateBin:~# apt install apache2 php -y 

root@privateBin:~# curl https://github.com/PrivateBin/PrivateBin/archive/refs/tags/1.6.2.zip # A mettre à jour pour avoir la dernière version 

root@privateBin:~# cd /var/www/html 

root@privateBin:/var/www/html# unzip /home/root/PrivateBin-1.6.2.zip 

root@privateBin:/var/www/html# mv PrivateBin-1.6.2/ PrivateBin 

root@privateBin:/var/www/html# chown -R www-data:www-data PrivateBin 

root@privateBin:/var/www/html# chmod -R g+rw PrivateBin 

 

# Mis à jour de sécurité automatique 

root@privateBin:~# apt install unattended-upgrades -y 

root@privateBin:~# apt install apt-config-auto-update                                 # Disponible sur debian 12 

root@privateBin:~# nano /etc/apt/apt.conf.d/50unattended-upgrades 

root@privateBin:~# dpkg-reconfigure --priority=low unattended-upgrades 

root@privateBin:~# nano /etc/apt/apt.conf.d/20auto-upgrades                 # Vérifier si les valeurs sont bien à 1 