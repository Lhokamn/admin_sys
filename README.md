# preparation_serveur

Permettre au débutant de découvrir l'openSource et Linux à travers des outils simple.

Le site GitHub est en français pour permettre aux personnes non-anglophone de s'initier au monde de l'open source.

---

## Navigation

**[Apps](https://doc.cclaudel.fr/apps)** --- **[Docker](https://doc.cclaudel.fr/docker)** --- **[ssh](https://doc.cclaudel.fr/ssh)**

## Les Distributions Linux utilisés

Pour le moment, le Git va se concentrer sur les distributions de la Debian (packages .deb). Notamment Debian et Ubuntu pour leur faciliter la prise en main.

1. [Site Web Debian](https://www.debian.org/index.fr.html)

2. [Site Web Ubuntu](https://www.ubuntu-fr.org)

## Script d'installation

Ce script permet de faire le minimum pour sécuriser un serveur Linux.

- Installation de Openssh-server avec la configuration suivante [sshd_config](https://github.com/Lhokamn/preparation_serveur/tree/main/ssh/sshd_config) (modifiable en fonction de vos besoin)
- Installation de fail2ban avec la configuration suivante [jail.local](https://github.com/Lhokamn/preparation_serveur/tree/main/ssh/jail.local) (modifiable en fonction de vos besoin)
- Installation de UFW 
- Mise en place d'une adresse IPv4 static
- Désactivation de l'IPv6 ( ? modifier selon vos usages)

### OpenSSH Server
- **Description** : OpenSSH Server est une implémentation libre du protocole SSH (Secure Shell) qui permet un accès sécurisé à distance à un système Linux. Il fournit des services d'authentification cryptée et de communication sécurisée sur un réseau non sécurisé.

- **Utilisation typique** : Permet aux utilisateurs distants de se connecter en toute sécurité à un serveur et d'exécuter des commandes à distance. Il est essentiel pour l'administration système à distance.

### Fail2Ban
- **Description** : Fail2Ban est un système de prévention d'intrusion qui surveille les journaux système pour détecter des activités malveillantes répétées (comme des tentatives de connexion échouées) et bloque dynamiquement les adresses IP sources associées à ces activités.

- **Utilisation typique** : Protège contre les attaques par force brute en bloquant automatiquement les adresses IP qui montrent des signes d'activité malveillante, renforçant ainsi la sécurité du système.

### Uncomplicated Firewall *UFW*
- **Description** : UFW est une interface en ligne de commande pour iptables, le système de pare-feu netfilter sous Linux. Il vise à simplifier le processus de configuration d'un pare-feu pour les utilisateurs non experts, tout en offrant une protection robuste.
    
- **Utilisation typique** : Permet de configurer facilement les règles de pare-feu pour autoriser ou bloquer le trafic réseau sur un système Linux. UFW est souvent utilisé pour limiter l'accès à certaines applications ou services, renforçant ainsi la sécurité du système.

###
## Open Source

Un logiciel open source est un logiciel qui respecte les règles de l'Open Source Initiative([opensource.org](https://opensource.org/))