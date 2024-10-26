# SSH

Le SSH permet de communiquer de manière sécurisé entre plusieurs machine d'un réseau.

Il existe plusieurs façon de sécurisés le ssh, mais ici nous allons voir la base.

## configuration sshd

sshd est pour un serveur ssh (à l'inverse de ssh qui est pour le client).

On va pouvoir définir qui est autorisés à faire du ssh sur la machine et qui est interdit

```config
# /etc/ssh/sshd_config

# Empêcher l'utilisateur root de se connecter
PermitRootLogin no

# Interdire la connexion root avec un mot de passe
PasswordAuthentication no

# Empêcher les mots de passe vides
PermitEmptyPasswords no

# Mettre un timeout de 15 minutes
ClientAliveInterval 900
ClientAliveCountMax 0

# Utiliser uniquement le protocole SSH 2
Protocol 2

# Limiter le nombre de tentatives de connexion
MaxAuthTries 3

```

## jail.local

Permet de bannir automatiquement pour des services. Pour chaque service il faut rajouter un block de configuration
```local
[DEFAULT]
bantime = 3600
findtime = 3600
maxretry = 3
enabled = true
banaction = ufw

[sshd]
mode = normal
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
```