# Script s'installation d'apache guacamole 1.5.3
# aide d'installation : https://www.it-connect.fr/tuto-apache-guacamole-bastion-rdp-ssh-debian/

sudo apt-get update

# Installation packages
sudo apt-get install build-essential libcairo2-dev libjpeg62-dev  libpng-dev libtool-bin uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev -y

# ===================================================== #
#                                                       #
#        Installation du serveur apache guacamole       #
#                                                       #
# ===================================================== # 
versionAG="1.5.3"

# R�cup�ration des fichiers source dans le dossier tmp sous forme d'archive
cd /tmp
wget https://downloads.apache.org/guacamole/$versionAG/source/guacamole-server-$versionAG.tar.gz

# d�compression de l'archive
tar -xzf guacamole-server-$versionAG.tar.gz
cd guacamole-server-$versionAG/

# Pr�paration � la compilation
sudo ./configure --with-init-dir=/etc/init.d

# Si une erreur se pr�sent il faut essayer la commande suivante
# sudo ./configure --with-init-dir=/etc/init.d --disable-guacenc

# Compilation d'apache guacamole
sudo make

# Installation des composants
sudo make install

# Mises � jour des lien des librairies
sudo ldconfig

# Cr�ation et execution du service guacd
sudo systemctl daemon-reload
sudo systemctl start guacd
sudo systemctl enable guacd

# Gestion de l'arborescence
sudo mkdir -p /etc/guacamole/{extensions,lib}

# ===================================================== #
#                                                       #
#        Installation du client apache guacamole        #
#                                                       #
# ===================================================== # 

versionTomcat="9"

# Installation des paquets
sudo apt install tomcat$versionTomcat tomcat$versionTomcat-admin tomcat$versionTomcat-common tomcat$versionTomcat-user -y

# R�cup�ration du bianire d'apache guacamole client sous forme d'archive
cd /tmp
wget https://downloads.apache.org/guacamole/$versionAG/binary/guacamole-$versionAG.war

# d�placement de la librairie
sudo mv guacamole-$versionAG.war /var/lib/tomcat$versionTomcat/webapps/guacamole.war

# On red�marre le service tomcat
sudo systemctl restart tomcat$versionTomcat guacd

# ===================================================== #
#                                                       #
#               Base de donn�es mariaDB                 #
#                                                       #
# ===================================================== # 

# Installation des paquets
sudo apt-get install mariadb-server -y

# S�curisation de l'installation
sudo mysql_secure_installation

# Connexion � la bdmysql
mysql -u root -p


## Commande � rentrer dans la bd
# CREATE DATABASE guacadb;
# CREATE USER 'guaca_nachos'@'localhost' IDENTIFIED BY 'P@ssword!';
# GRANT SELECT,INSERT,UPDATE,DELETE ON guacadb.* TO 'guaca_nachos'@'localhost';
# FLUSH PRIVILEGES;
# EXIT;

# Ajout de l'extension mysql
cd /tmp
wget https://downloads.apache.org/guacamole/$versionAG/binary/guacamole-auth-jdbc-$versionAG.tar.gz

# D�compression de l'archive
tar -xzf guacamole-auth-jdbc-$versionAG.tar.gz

# On d�place l'executable
sudo mv guacamole-auth-jdbc-$versionAG/mysql/guacamole-auth-jdbc-mysql-$versionAG.jar /etc/guacamole/extensions/

# Pour r�cup�rer le connecteur mysql il faut se rendre sur le lien suivant :
#       https://dev.mysql.com/downloads/connector/j/

# A date du 12/03/2024
cd /tmp
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.33.tar.gz

tar -xzf mysql-connector-j-8.0.33.tar.gz
sudo cp mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar /etc/guacamole/lib/

# On copie la structure d'apache guacamole dans la bd cr�e
cd guacamole-auth-jdbc-$versionAG/mysql/schema/
cat *.sql | mysql -u root -p guacadb

sudo nano /etc/guacamole/guacamole.properties

## MySQL � modifier avec les infos rentr�s
# mysql-hostname: 127.0.0.1
# mysql-port: 3306
# mysql-database: guacadb
# mysql-username: guaca_nachos
# mysql-password: P@ssword!

# On modifie la conf
sudo nano /etc/guacamole/guacd.conf

## Code � int�grer
# [server] 
# bind_host = 0.0.0.0
# bind_port = 4822

# On red�marre tous les services
sudo systemctl restart tomcat$versionTomcat guacd mariadb