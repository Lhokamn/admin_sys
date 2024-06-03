# OCS 

OCS est un outil de déploiement de paquet sur un parc informatique

## Information générales

Machine : 
- 2 vCPU
- 2 Go vRAM
- 20 Go stockage
- Debian 12

Package  :
- apache2
- php

# Installation sur la machine Debian 12

## Modification générales 

On change le hostname de notre machine :

```shell
root@debian-template:~# hostnamectl set-hostname ocs-server
```

Et on met la machine à jour (toujours une bonne pratique !)
```shell
root@glpi-server:~# apt update && apt upgrade -y
```

## Installation package et dépendances

La première étape d'installer les paquets pour que l'application fonctionne
```shell
apt install git make cmake gcc make build-essential -y
```

Puis il faut installer les modules / dépendances
```shell
apt install libapache2-mod-perl2 libapache-dbi-perl libapache-db-perl libapache2-mod-php -y 
apt install php php-zip php-pclzip php-gd php-mysql php-soap php-curl php-json php-xml php-mbstring -y
```

On installe ensuite l'application perl
```shell
apt install perl libxml-simple-perl libcompress-zlib-perl libdbi-perl libdbd-mysql-perl libnet-ip-perl libsoap-lite-perl libio-compress-perl libapache-dbi-perl libapache2-mod-perl2 libapache2-mod-perl2-dev libdbd-mysql-perl libnet-ip-perl libxml-simple-perl libarchive-zip-perl -y
```
```shell
cpan install XML::Entities Apache2::SOAP Net::IP Apache::DBI Mojolicious Switch Plack::Handler Archive::Zip
```

## Création de la bd mysql
```shell
apt install mariadb-server -y
```
```shell
mysql_secure_installation


NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

Dans notre cas, le mot de passe de root est ``azerty``

On se c
```shell
mysql -u root -p
```

```sql
CREATE DATABASE ocs_inventory;
CREATE USER 'ocsuser'@'localhost' IDENTIFIED BY 'Mot2Passe';
GRANT ALL PRIVILEGES ON ocs_inventory. * TO 'ocsuser'@'localhost';
exit;
```

## Installation d'OCS

On récupère le code source de OCS sur github, on l'extrait puis on l'execute
```shell
cd /tmp
wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.12.1/OCSNG_UNIX_SERVER-2.12.1.tar.gz
tar xzf OCSNG_UNIX_SERVER-2.12.1.tar.gz
rm OCSNG_UNIX_SERVER-2.12.1.tar.gz
cd OCSNG_UNIX_SERVER-2.12.1
sh setup.sh
```

A l'execution, on peut laisser toutes les valeurs par défaut pour OCS.

## Gestion d'apache2

On modifie les valeurs de la base de données pour quelle correspondent à celle que nous avons créées
```shell
nano /etc/apache2/conf-available/z-ocsinventory-server.conf
```

On modifie les valeurs de la base de données pour quelle correspondent à celle que nous avons créées
```shell
nano /etc/apache2/conf-available/zz-ocsinventory-restapi.conf
```

On modifie les droits pour OCS 

```shell
chown www-data:www-data /var/lib/ocsinventory-reports
chmod 755 /var/lib/ocsinventory-reports
```

On active ensuite notre virtual host et notre module api

```shell
a2enconf z-ocsinventory-server.conf
a2enconf ocsinventory-reports
a2enconf zz-ocsinventory-restapi.conf
```

On rédémarre le service apache2 pour que la configuration soit bien prise en compte 

```shell
service apache2 restart
```

## Configuration OCS part 2 via interface Web

Pour se connecter en web sur la machine OCS, il faut aller au lien comme l'exemple ci dessous :
``http://<mon_ip>/ocsreports``

Là nous allons avoir une page de connexion à notre bd où il faut renseigner :
- l'utilisateur
- le mot de passe de l'utilisateur
- Le nom de la bd
- La machine hote de la bd
- Désactiver le SSL 

Il faut cliquer sur send et cela va donner le login et mot de passe par défaut

Si on veut on peut changer la valeur de taille de fichier qu'on peut poster avec les attributs : ``php_value post_max-size`` et ``php_value upload_max-size`` dans le fichier ``/etc/apache2/conf-available/ocsinventory-reports.conf``


Il faut aussi executer cette commande pour que l'installation d'OCS ne se refassent pas
```shell
rm /usr/share/ocsinventory-reports/ocsreports/install.php
```
