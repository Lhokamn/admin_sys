# Docker et Docker-compose

Docker est un outil open source permettant de virtualiser des systemes léger.
Cet espace créer s'appel un conteneur et ce conteneur et composé d'image.

Un objectif des objectifs de docker est vraiment qu'il soient le plus léger à faire tourner sur une machine hôte

## Installation Docker et Docker-compose

```sh
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg; done

apt-get update
apt-get install ca-certificates curl gnupg -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

apt install docker-compose -y
```

Télécharger le script [ici](https://doc.cclaudel.fr/apps/docker/installation.sh)

## Docker

Se lance à partir d'une image docker trouvable sur le suite :

Mais il est possible de créer son propre conteneur docker avec un Dockerfile.
Plus d'information sur le site officiel de Docker : [docs.docker.com](https://docs.docker.com/engine/reference/builder)

Au démarrage d'un docker, on peut attribué des arguments qui seront pris en compte par le processus, notamment le port d'écoute, tout ça est en ligne de commande

> Exemple de commande Docker 
```sh
docker run -d -p 9443:80 \
    -e DOMAIN_NAME=example.com \
    -e CURRENT_USER=$USER \
    -v $(pwd)/data:/app/data \
    --name mon_service mon_image
```
## Docker-compose

Evolution de docker où toutes les informations sont stockées dans un fichier **compose.yml** (ou *docker-compose.yml* pour les anciennes versions. Toujours comptable avec les nouvelles).

Il est possible de faire démarrer plusieurs services dans un même conteneur.
 
> Fichier compose.yml correspondant à la commande docker
```yaml
version: '3'
services:
  mon_service:
    image: mon_image
    ports:
      - "9443:80"
    environment:
      - DOMAIN_NAME=example.com
      - CURRENT_USER=user123
    volumes:
      - ./data:/app/data
```

**Attention**, l'indentation d'un fichier ``.yaml`` est très importantes ! 


### Liste des correspondance Docker - Docker-compose

| **Utilité** | **Docker** | **docker-compose** |
|-------------|------------|--------------------|
| Indication de l'image | --name | image: | 
| Port ouvert | -p | ports: |
| Variable d'environnements | -e | environnements: |
| Volumes de stockage | -v | volumes: |