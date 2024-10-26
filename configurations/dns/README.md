# DNS

Un DNS est une translation entre un texte compréhensible par les humains (ex : google.com, cclaudel.fr) en IP (plus compliqué à retenir). 
Il est possible d'avoir un DNS public pour permettre au personnes extérieur d'avoir un accès à nos services, mais pour cela, il faut payé auprès d'un hébergeur (OVH, Google, Amazon.).
Il est possible d'avoir des DNS en interne pour les services n'ayant pas besoin d'être exposé.


# Exemple

Prenons comme exemple le réseau et le domaine suivant :
- réseau : 10.0.0.0/24
- dns : cclaudel.demo

# Commandes

- Installation des paquets
```sh
$ sudo apt install bind9 dnsutils
```

Il faut ensuite vérifier que le DNS fonctionne bien avec la commande suivante
```sh
$ cat /etc/resolv.conf
```
Il faut bien retenir la valeur du nameserver qui va en sortir. elle nous sera utile dans la configuration

## Création du "cache DNS" 
```sh
$ sudo vi /etc/bind/named.conf.options
```conf
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        forwarders {
                10.0.0.<ip>;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        //dnssec-validation auto;

        dnssec-validation no;
        listen-on { 10.0.0.<ip>; };

        //listen-on-v6 { any; };
};
```
remplacer la valeur de *Mon_IP* par votre valeur obtenu plus tôt

- Tester la configuration puis redémmarer le service de cache
```sh
$ sudo named-checkconf /etc/bind/named.conf
$ sudo service bind9 restart
```

## Création de la zone locale

Pour créer la zone locale, nous allons créer 3 fichiers :
- 1 fichier de configuration reverse DNS (IP -> Nom)
- 1 fichier de configuration DNS (Nom -> IP)
- 1 fichier lien les deux fichiers

- fichier reverse DNS
```sh
$ sudo vi /etc/bind/db.10.0.0
```
```conf
; BIND reverse data file for cclaudel.demo
;
$TTL    604800
@    IN    SOA    cclaudel.demo. root.cclaudel.demo. (
                  1        ; Serial
             604800        ; Refresh
              86400        ; Retry
            2419200        ; Expire
             604800 )    ; Negative Cache TTL
;
@      IN    NS     cclaudel.demo
IP_MACHINE      IN    PTR    client.cclaudel.demo.
IP_MACHINE    IN    PTR    srv.cclaudel.demo.
```

- fichier DNS
```sh
$ sudo vi /etc/bind/db.cclaudel.demo
```
```conf
; BIND data file for cclaudel.demo domain
;
$TTL    604800
@    IN    SOA    cclaudel.demo. root.cclaudel.demo. (
                  2        ; Serial
             604800        ; Refresh
              86400        ; Retry
            2419200        ; Expire
             604800 )    ; Negative Cache TTL
;
@      IN      NS      cclaudel.demo.
@      IN      A       10.0.0.<ip>

srv    IN      A       10.0.0.<ip>
client IN      A       10.0.0.<ip>

dns     IN      CNAME  srv
```

- fichier de liaison
```sh
$ sudo vi /etc/bind/named.conf.local 
```
```conf
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "cclaudel.demo" {
    type master; file "/etc/bind/db.cclaudel.demo";
};
zone "0.0.10.in-addr.arpa" {
    type master; file "/etc/bind/db.10.0.0";
};
```

Ce fichier ne sera jamais écraser par les mises du cache

- Redémarrage du services
```sh
$ sudo service bind9 restart
```