#!/bin/bash -e

###########################################
#            Global Information
###########################################

## Auteur
# Corentin CLAUDEL corentin.claudel@etu.univ-lyon1.fr
# Angelo NAUDTS angelo.naudts@etu.univ-lyon1.fr

## Machine
# VM Linux : Fedora 39 Workstation


###########################################
#               Variable
###########################################

## Attribut User
UIDuser=4242
userName="ansible"
#userMDP="12345678a!"
userShell='/bin/bash'

## Attribut group
GIDgroup=5678
groupeName="ansible"

## Environnement

# Repository variable (\ = jump line) (2/5)
repoindicator="DACS"
repoName="name=Fake Packages for DACS"
repobaseurl="baseurl=http://repository.dacs.fr/el/8/x86_63/dacs"
repoenabled="enabled=1"
repogpgcheck="gpgcheck=1"
repopriority="priority=1"


###########################################
#               Script
###########################################

# Group Creation (a voir si on met la verif de si le groupe existe)
groupadd -g $GIDgroup $groupeName 

# user Creation
useradd -u $userName -g $GIDgroup -m -d /home/$userName -s $userShell $userName

## ===== ssh part =====

# file keys
touch -p ~$userName/.ssh/authorized_keys

# update right on directory 
chmod -R ansible:ansible ~$userName/.ssh
chmod -r 600 ~$userName/.ssh

# add ansible in sudoers file
echo "ansible    (ALL) = (ALL) NOPASSWD: ALL >> /etc/sudoers"

# add custom repository
echo "$repoindicator\"


