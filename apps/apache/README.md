# Comment créer un service apache 


Point important, il faut après chaque modification redémmarrez le service apache
```shell
sudo systemctl restart apache2
```

## Installation apache 

- Debian / Ubuntu
```shell
sudo apt update && sudo apt install apache2
```

- CentOS
```shell
sudo yum update && sudo yum install httpd
```

## Gestion du pare-feu

- UFW
```shell
sudo ufw allow "Apache Full"
```

## Cr�ation d'un virtual host
Pour créer un virtual host il faut créer un fichier de configuration pour apache

```shell
sudo nano /etc/apache2/sites-available/mon_domaine.conf
```

```conf
<VirtualHost *:80>
   ServerName doc.cclaudel.fr
   DocumentRoot /var/www/<mondomaine>
</VirtualHost>
```

Il faut ensuite bien pensé à activer la conf du domaine

```shell
sudo a2ensite mon_domaine.conf
```

## Gestion d'un reverse Proxy 

Avoir un module reverse proxy peut être utile dans le cas d'utilisation de docker

Il faut activé les modules apache suivants
```shell
sudo a2enmod proxy
sudo a2enmod proxy_http
```

Dans le virtual host :
```conf
<VirtualHost *:80>
    ServerName doc.cclaudel.fr

    ProxyPreserveHost On
    ProxyPass / http://localhost:<mon_port>/
    ProxyPassReverse / http://localhost:<mon_port>/
</VirtualHost>
```

## Certificat du site

La première étape est d'activé le module ssl pour le site web

```shell
sudo a2enmod ssl
```

### Auto-signé (test)

```shell
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
```
**Explication commande**
- openssl : Il s'agit de l'outil en ligne de commande permettant de créer et de gérer les certificats, les clés et autres fichiers OpenSSL.
req -x509 : Cela spécifie que nous voulons utiliser la gestion des demandes de signature de certificat (CSR) en utilisant le protocole X.509. X.509 est une norme d'infrastructure à clé publique à laquelle TLS adhère pour la gestion des clés et des certificats.
- nodes : Cela indique à OpenSSL de sauter l'option de sécurisation de notre certificat avec une phrase secrète. Nous avons besoin qu'Apache puisse lire le fichier sans intervention de l'utilisateur lors du démarrage du serveur. Une phrase secrète empêcherait cela de se produire, car nous devrions la saisir après chaque redémarrage.
- days 365 : Cette option définit la durée pendant laquelle le certificat sera considéré comme valide. Nous l'avons réglé ici pour un an. De nombreux navigateurs modernes rejettent tout certificat valide depuis plus d'un an.
- newkey rsa:2048 : Cela spécifie que nous voulons générer simultanément un nouveau certificat et une nouvelle clé. Nous n'avons pas créé la clé requise pour signer le certificat lors d'une étape précèdente, donc nous devons la créer en même temps que le certificat. La partie rsa:2048 indique de créer une clé RSA de 2048 bits.
- keyout : Cette ligne indique à OpenSSL où placer le fichier de clé privée générée que nous sommes en train de créer.
- out : Cela indique à OpenSSL où placer le certificat que nous sommes en train de créer.

Il faut ensuite modifier le fichier virtual host

```conf
<VirtualHost *:443>
   ServerName <mon_domaine>
   DocumentRoot /var/www/<your_domain_or_ip>

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
```
Bien penser à mettre le port d'écoute sur 443

### Let's Encrypt (prod)

IL faut installer les paquets suivants 

```shell
sudo apt-get update
sudo apt-get  install certbot python3-certbot-apache
```

Ensuite on fait la requête du certificat
```shell
certbot --apache -d doc.cclaudel.fr
```
```
certbot --apache -d project.cclaudel.fr
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): lhokam.claudel@gmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y
Account registered.
Requesting a certificate for project.cclaudel.fr

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/project.cclaudel.fr/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/project.cclaudel.fr/privkey.pem
This certificate expires on 2024-06-18.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for project.cclaudel.fr to /etc/apache2/sites-enabled/project.conf
Congratulations! You have successfully enabled HTTPS on https://project.cclaudel.fr

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Vérifier que le fichier de configuration récupère bien les certificats de let's encrypt
```
<VirtualHost *:80>
    ServerName doc.cclaudel.fr
    Redirect permanent / https://doc.cclaudel.fr/
RewriteEngine on
RewriteCond %{SERVER_NAME} =doc.cclaudel.fr
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>

    ServerName doc.cclaudel.fr

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    SSLEngine on

    SSLCertificateFile /etc/letsencrypt/live/doc.cclaudel.fr/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/doc.cclaudel.fr/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
```


## Exemple de conf

1. Avec reverse proxy + SSL autosigné

```conf

<VirtualHost *:443>
    ServerName doc.cclaudel.fr

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
```

2. Forcer l'utilisation du ports 443 à la place du 80
```conf
<VirtualHost *:80>
    ServerName doc.cclaudel.fr
    Redirect permanent / https://doc.cclaudel.fr/
</VirtualHost>

<VirtualHost *:443>
    ServerName doc.cclaudel.fr
    DocumentRoot /var/www/<mondomaine>
</VirtualHost>
```