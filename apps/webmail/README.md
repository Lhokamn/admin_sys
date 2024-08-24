# Création d'un webmail

Pour créer un webmail et ne pas dépendre d'un des GAFAM, il peut être interessant d'avoir son propre webmail.

## Pré-requis
- Un nom de domaine personnalisé
- un VPS avec au minimum :
    - 2 vCPU
    - 2 Go vRAM
    - 30 Go de stockage
    - Une connexion internet
    - Un nom de domaine

Cette installation est faites sur une debian 12 et nous allons installer plusieurs paquet :
- docker 
- openssh-server
- ufw
- haproxy
- certbot

# Installation

Dans cette partie, nous allons voir tout ce que nous allons installer et comment y installer tout en incluant de la sécurité

## Préparation de la machine

Pour toutes cette première partie, nous allons nous connecter en tant que l'utilisateur root pour faire la configuration 

```sh
su -
apt update && apt upgrade -y
```

Maintenant nous allons installer docker en utilisant le script disponible [ici](https://doc.cclaudel.fr/apps/docker/docker_installation.sh) 
```sh
cd /tmp
wget https://doc.cclaudel.fr/apps/docker/docker_installation.sh
chmod 744 docker_installation.sh
./docker_installation.sh
```

Si le vps ne vous a donné accès uniquement au compte root pour le ssh, il faut créer un utilisateur standard (Root ne doit jamais pouvoir se connecter en ssh). Evidemment le nom de l'utilisateur doivent être changé.
A l'utilisateur créer, nous allons le rajouter dans le groupe docker et nous allons aussi créer un group pour autoriser les personnes de ce groupe à faire du ssh.

```sh
useradd -m -s /bin/bash standard_user
passwd admcld
usermod -aG docker admcld

groupadd sshAuthorize
usermod -aG sshAuthorize admcld

echo "AllowGroups sshAuthorize" >> /etc/ssh/sshd_config

systemctl restart sshd
```

Maintenant, nous allons créer un utilisateur qui va permettre de nous connecté à la machine et de faire des sauvegardes de nos mails en dehors du vps 

```sh
groupadd webmailSave
useradd -m -g webmailSave -s /bin/bash wssa
passwd wssa
usermod -aG sshAuthorize wssa
```

Création d'un utilisateur dans mailserver
```sh
email add user@domain password
```


Génration des clés dkim :
```sh
setup.sh config dkim
```