#!/bin/bash

cheminVaultWarden=/usr/local/vaultwarden

# Création du dossier 
mkdir $cheminVaultWarden

# Création d'un fichier .env
touch $cheminVaultWarden/.env

echo "domaine du site"
read domain

echo "DOMAIN=$domain" >> $cheminVaultWarden/.env

# Création d'un dossier pour stocker les informations du docker
mkdir /srv/vw-data/
chmod 700 /srv/vw-data/

# Génération de l'ADMIN token
admin_token=docker run --rm -it vaultwarden/server /vaultwarden hash 
echo "VAULTWARDEN_ADMIN_TOKEN=$admin_token" >> $cheminVaultWarden/.env
 

#install APACHE (pour haproxy)
apt update && apt install apache2 -y

a2enmod proxy
a2enmod proxy_http

# Configuration de Apache
# Le port d'ouverture correspond à celui dans le docker-compose
configApache="<VirtualHost *:80> 
    ServerName $domain

    ProxyPreserveHost On
    ProxyPass / http://localhost:9443/  

    ProxyPassReverse / http://localhost:9443/

</VirtualHost>"

echo $configApache > /etc/apache2/sites-available/vaultwarden.conf

# On active la conf de vaultwarden
a2ensite vaultwarden.conf
systemctl restart apache2

ufw allow 80/tcp
ufw reload


cp compose.yaml $cheminVaultWarden/compose.yaml
cd $cheminVaultWarden/compose.yaml
docker-compose up-d
