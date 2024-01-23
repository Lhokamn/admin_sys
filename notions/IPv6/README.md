# Configuration IPv6

## Commande Routeur
1. Activer l'IPv6 sur un routeur
```js
switch(config)# IPv6 unicast-routing
```

2. Entrée dans la configuration d'interface
```js
switch> en
switch# conf t
switch(config)# int <nom_int>
```

3. Ajouter une adresse IPv6
```js
switch(config-if)# ipv6 addr <mon_ipv6>/<mon_prefixe>
```

4. Ajouter l'adresse link-local
```js
switch(config-if)#ipv6 add FE80::1 link-local
```