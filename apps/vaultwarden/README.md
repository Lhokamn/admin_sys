# VaultWarden

[VaultWarden](https://www.vaultwarden.net/) est un serveur permettant de stockée ces mots de passes en auto-hébergé.

Alternative [BitWarden](https://bitwarden.com/) totalement open-source (basé qur le code de ce dernier !). Le code source est disponible [ici](https://github.com/dani-garcia/vaultwarden)

## Pré-requis

Pour installer VaultWarden, il vous faut une machine Linux avec [Docker](https://doc.cclaudel.fr/docker/), un DNS et un certificats https.

## Fichier vaultwarden
Pour utiliser vaultwarden, nous allons utilisés un fichier [compose.yaml](https://github.com/Lhokamn/preparation_serveur/tree/main/apps/VaultWarden/compose.yaml), et un fichier .env pour que les informations ne soient pas disponible directement sur le fichier docker.

Si vous utilisez le [script d'installation](https://github.com/Lhokamn/preparation_serveur/tree/main/apps/vaultwarden/vaultwarden_installation.sh). Un nom de dommaine vous sera demandé (pas besoin de mettre https://). Et l'admin token sera généré et mis dans le fichier .env.

d'autres informations peuvent être rajoutés dans le fichier .env, je vous laisse regarder le Git Officiel de VaultWarden.

## DNS et Certificats https
Pour utiliser VaultWarden il faut un DNS avec un certificat pour avoir une connexion sécurisé (logique pour un gestionnaire de mot de passe !). 
Voir les cours de notions [ici](https://doc.cclaudel.fr/notions/) 