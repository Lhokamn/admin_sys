# Open LDAP

Permet de gérer les comptes et les accès sur un réseau. C'est un équivalent Open Source de l'Active Directory de Microsoft

## Installation

Pour installer ce service il faut une machine Linux de préférence pour rester dans la logique OpenSource


## Déploiement avec Docker

Prérequis : 
- Avoir installé docker et docker-compose

Fichier docker-compose :

```yml
version: '3'

services:
  openldap-server:
    image: osixia/openldap:latest
    container_name: ${OPEN_LDAP_SERVEUR}
    ports:
      - "389:389"
      - "636:636"
    hostname: ${HOSTNAME_SERVER}
    environment:
      - LDAP_ORGANISATION=${ORGANISATION}
      - LDAP_DOMAIN=${DOMAIN}
      - LDAP_ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - LDAP_BASE_DN=${DN}
    volumes:
      - /data/slapd/database:/var/lib/ldap
      - /data/slapd/config:/etc/ldap/slapd.d
    detach: true

  phpldapadmin:
    image: osixia/phpldapadmin:latest
    container_name: phpldapadmin
    ports:
      - "10080:80"
      - "10443:443"
    hostname: phpldapadmin-service
    environment:
      - PHPLDAPADMIN_LDAP_HOSTS=${OPEN_LDAP_SERVEUR}
    links:
      - ${OPEN_LDAP_SERVEUR}:ldap-host
    detach: true
```

Puis on complète avec un fichier ``.env``

```.env
## Configuration des Docker

# Nom du conteneur Docker du serveur LDAP
OPEN_LDAP_SERVEUR="openLdap-Server"

# Nom de la machine Docker
HOSTNAME_SERVER="Mon-Serveur-LDAP"

# Nom de votre organisation
ORGANISATION="Mon Organisation"

# Correspond à votre domaine (sous la forme nom.suffixe)
DOMAIN="monDomaine.local"

# Correspond à votre mot de passe du compte Admin
ADMIN_PASSWORD="SuperSecretPassw0rd"

# Dépend de la variable DOMAIN sous la forme <dc=nom,dc=suffixe>
DN="dc=monDomaine,dc=local"
```