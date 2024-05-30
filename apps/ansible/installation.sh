#!/bin/bash -e

# mise à jour des paquets
apt update && apt upgrade -y

# Installation des paquets apt
apt install python3 python3-pip sshpass sudo -y

# Création d'un compte sudoers
adduser admansible
usermod -aG sudo admansible

echo "Définition du mot de passe de l'utilisateur admansible"
passwd admansible

# Installation des paquets pip
pip install ansible

# Ajout de controller node dans le fichier Host
echo "$(hostname -I | awk '{print $1}')  $(hostname -f)" | sudo tee -a /etc/hosts

nbNode=1
while true; 
do
    echo "Veuillez entrée l'IP du compute node $nbNode (ou appuyez sur Entrée pour quitter) :"
    read ip
    echo "Veuillez entrée le hostname du compute node $nbNode (ou appuyez sur Entrée pour quitter) :"
    read hostname

    if [ -z "$ip" ] || [ -z "$DNS" ], then
        break
    else 
        echo "$ip $hostname" | sudo tee -a /etc/hosts
    fi

    # remise à zero des variables pour la comparaison au test d'après
    unset $ip
    unset $hostname

    let $nbNode=$nbNode+1

done