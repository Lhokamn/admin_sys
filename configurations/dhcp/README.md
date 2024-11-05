# DHCP

Le DHCP permet d'attribuer automatique des IP dans un réseau. Nous allons voir comment le mettre en place grâce à une machine linux

# Commande

- Installation du paquet
```sh
$ sudo apt install isc-dhcp-server
```
Lors de l'installation, des erreurs vont se produire car le service n'est pas configuré. Il faudra le redémmarer dans un deuxième temps

- Modification de la configuration :
```sh
$ sudo vi /etc/default/isc-dhcp-server
```

```conf
# Aller a ces lignes là :
INTERFACESv4="<interface>"
INTERFACESv6="<interface>"
```
Il faut aller modifier dans le fichier de configuration, le nom de l'interface où faire le DHCP. On peut également le faire pour créer un serveur DHCPv6(pas encore intégré)

- Modification du daemon
```sh
$ sudo vi /etc/dhcp/dhcpd.conf
```

```conf
# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#

# option definitions common to all supported networks...
option domain-name "<domaine_local>";
option domain-name-servers 10.0.0.254, 8.8.8.8;

default-lease-time 600;
max-lease-time 7200;

# The ddns-updates-style parameter controls whether or not the server will
# attempt to do a DNS update when a lease is confirmed. We default to the
# behavior of the version 2 packages ('none', since DHCP v2 didn't
# have support for DDNS.)
ddns-update-style none;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
#authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

# No service will be given on this subnet, but declaring it helps the 
# DHCP server to understand the network topology.

# mon réseau
subnet <mon_réseau> netmask <mon masque> {
        range 10.0.0.1 10.0.0.253;
        option routers 10.0.0.254;
# Configuration d'une réservation DHCP
#        host client-ubuntu {
#            hardware ethernet 08:00:27:c3:0e:20;
#            fixed-address 10.0.0.1;
#        }
}

## Autre réseau
#subnet 10.152.187.0 netmask 255.255.255.0 {
#}

#(...)
```

- Vérification des erreurs
```sh
$ sudo dhcpd -t
```

S'il n'y a pas d'erreurs, alors on peut redémarrer le service
```sh
$ sudo service isc-dhcp-server restart
```
