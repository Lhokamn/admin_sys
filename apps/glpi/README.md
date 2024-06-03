# GLPI

GLPI est un logiciel libre de gestion de parc informatique permettant d'avoir une solution de ticketing gratuite pour le support informatique, de gérer l'inventaire des équipements, notamment les ordinateurs et les téléphones, de gérer ses contrats, ses licences, ses consommables, ses baies serveurs.

## Information générales

Machine : 
- 2 vCPU
- 2 Go vRAM
- 20 Go stockage
- Debian 12


Package  :
- php 8.2
- apache2
-  mariadb

# Installation


## Modification générales 
On change le hostname de notre machine :

```shell
root@debian-template:~# hostnamectl set-hostname glpi-server
```

Et on met la machine à jour (toujours une bonne pratique !)
```shell
root@glpi-server:~# apt update && apt upgrade -y
```

## Installations du socle LAMP

Installation des packages 
```shell
apt-get install apache2 php mariadb-server -y
```

Et installation des extensions :
```shell
apt-get install php-xml php-common php-json php-mysql php-mbstring php-curl php-gd php-intl php-zip php-bz2 php-imap php-apcu -y
```

Bonus, pour le mettre dans un entreprise avec un AD, il faut installer le package ``php-ldap``
```shell
apt-get install php-ldap
```

## Préparation de la base de données 

On sécurise la configuration de mysql :
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


Maintenant que mariaDB est sécurisés, il faut créer la base de donnée qui va contenir nos infos GLPI :

On se conencte à la base de donnée
```shell
mysql -u root -p
```

Puis on crée la base de donnée ainsi que l'utilisateur qui va gérer cette bd :

```sql
CREATE DATABASE glpi_database;
GRANT ALL PRIVILEGES ON glpi_database.* TO glpi_adm@localhost IDENTIFIED BY "Mot2Passe";
FLUSH PRIVILEGES;
EXIT;
```

## Installation de GLPI

On récupère le dépot git de GLPI pour avoir la version. On stocke les fichiers dans le dossier /tmp pour que les fichiers soient supprimés au prochains redémarrage

```shell
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.10/glpi-10.0.10.tgz
tar -xzvf glpi-10.0.10.tgz -C /var/www/
```

Ensuite nous allons donné les droits à l'utilisateur ``www-data`` sur tout le repertoire ``/var/www``
```shell
chown -R www-data:www-data /var/www/glpi/
```

Pour sécuriser l'installation de GLPI, il faut créer des dossiers en dehors de la racine

Pour les fichier de configuration :
```shell
mkdir -p /etc/glpi
chown www-data:www-data /etc/glpi/
mv /var/www/glpi/config /etc/glpi
```

Pareil pour les lib :
```shell
mkdir /var/lib/glpi
chown www-data:www-data /var/lib/glpi/
mv /var/www/glpi/files /var/lib/glpi
```

Et identique pour les logs :
```shell
mkdir /var/log/glpi
chown www-data:www-data /var/log/glpi
```

Dans le fichier de configurations, nous indiquons à GLPI ou aller chercher les nouveaux dossier créer :

Dans le fichier ``/var/www/glpi/inc/downstream.php`` il faut ajouter le contenu suivant :
```php
<?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
    require_once GLPI_CONFIG_DIR . '/local_define.php';
}
```

Pareil dans un second fichier ``/etc/glpi/local_define.php``
```php
<?php
define('GLPI_VAR_DIR', '/var/lib/glpi/files');
define('GLPI_LOG_DIR', '/var/log/glpi');
```

## Configuration Apache2

Il faut créer un fichier pour le virtualHost :
```shell
nano /etc/apache2/sites-available/glpi.conf
```

avec les informations suivantes :

Pour le moment nous utilisons une IP privée mais il faut mettre le nom DNS du serveurs.
```conf
<VirtualHost *:80>
    ServerName 192.168.198.9

    DocumentRoot /var/www/glpi/public

    # If you want to place GLPI in a subfolder of your site (e.g. your virtual host is serving multiple applications),
    # you can use an Alias directive. If you do this, the DocumentRoot directive MUST NOT target the GLPI directory itself.
    # Alias "/glpi" "/var/www/glpi/public"

    <Directory /var/www/glpi/public>
        Require all granted

        RewriteEngine On

        # Redirect all requests to GLPI router, unless file exists.
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
</VirtualHost>
```

Pour que la réécriture de la config fonctionne, il faut activer le module suivant 

```shell
a2enmod rewrite
```

Puis nous allons ajouter activer notre virtual et désactiver celui par défaut car il est inutile
```shell
a2ensite glpi.conf
a2dissite 000-default.conf
```

Pour finir avec apache2, nous allons faire en sorte qu'il se lance à chaque démarrage et le faire redémarrer pour que notre configuration soit bien prise en compte
```shell
systemctl enable apache2
systemctl restart apache2
```

## Configuration de php

Pour avoir un maximum de performance nous allons utilisés le module php-fpm

```shell
apt-get install php8.2-fpm -y
```

Puis on active les modules correspondants avant de redémarrer notre apache
```shell
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
systemctl reload apache2
```

Nous allons modifier le fichier ``/etc/php/8.2/fpm/php.ini`` pour activer l'option ``session.cookie_httponly``

```ini
session.cookie_httponly = on
```

Il faut ensuite redémarrer le service 
```shell
systemctl restart php8.2-fpm.service
```

Puis nous allons modifier le fichier ``glpi.conf`` pour indiquer que nous allons utiliser php8.2-fpm

```conf
<VirtualHost *:80>
    ServerName 192.168.198.9

    DocumentRoot /var/www/glpi/public

    # If you want to place GLPI in a subfolder of your site (e.g. your virt>
    # you can use an Alias directive. If you do this, the DocumentRoot dire>
    # Alias "/glpi" "/var/www/glpi/public"

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    <Directory /var/www/glpi/public>
        Require all granted

        RewriteEngine On

        # Redirect all requests to GLPI router, unless file exists.
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
</VirtualHost>
```

Et ne pas oublier de redémmarer apache2

## Configuration de GLPI part 2 (Interface Web)

A travers l'interface Web, il va falloir faire certaines actions :
- Indiquer la langue de GLPI
- Accepter la licence GNU
- Et enfin cliquer sur le bouton installer. cela va indiquer les options présentes et manquantes, il faut vérifier que tout ce que l'on veut est présent
- Pour configurer la base de donnée il faut indiquer où elle se situe, et les credentials. Dans notre cas cela donne :
    - localhost
    - glpi_adm
    - Mot2Passe
- Indiquer la base de donnée qui a déjà été créer

Une fois que tout cela est prêt. GLPI fonctionne !

## Dernière modification

- Changer les mots de passes des utilisateurs (lien dans le cadre orange)
- supprimer le fichier ``/var/www/glpi/install/install.php`` pour eviter qu'il relance une installation au redémarrage du serveur en cas de problème
