# BABARNET

Cet ensemble de script/configuration devrait permettre la
configuration d'un serveur BABARNET (xmpp/web) sur une Debian.

## Utilisation

Lancer `install.sh` en étant root. Si le script foire où si vous etes
pas sur debian lire la suite (et le script aussi quand meme).

## Description

Le dossier ejabberd contient la configuration d'ejabberd (.yml) ainsi
que qu'un diff par rapport à la conf par défaut. Le diff est juste là
à but informatif pour savoir ce qui change de la conf par défaut.

Le dossier apache contient un "site conf" à placer dans le dossier
sites-available d'apache, ainsi que le dossier `webroot` à placer à la
racine du site.

## Fonctionnement de la configuration d'apache

En gros apache a un fichier de conf principale qui inclus plusieurs
sous-fichiers de conf histoire de pas avoir un énorme fichier. Une
fois le fichier placé la commande `a2ensite` (Apache2 ENable SITE)
permet de rendre la conf "active" en créant un lien symbolique dans le
dossier `site-enabled`. La configuration principale d'apache inclus
uniquement le contenu des dossiers `*-enabled`. Ce découpage permet
d'activer/désactiver facilement des sites ou des options depuis les
commandes `a2*` qui se contentent de créer ou supprimer des liens
symboliques.

## Synchronisation avec le serveur "maitre"

En cours...

### Solution basique

Dans cette solution les serveurs esclaves sont uniquement utilisés
quand le maitre est mort. Quand le maitre est en vie, les esclaves
tournent à vide et ne servent a rien. Les serveurs esclaves forment
une chaine (dont la définition et l'ordre apparait dans la zone DNS du
nom de domaine).

Les clients XMPP sont censés respecter cette zone DNS et vont se
connecter au serveur suivant de la chaine si le serveur initial essayé
est mort.

Le serveur maitre dump régulièrement sa db dans un fichier *texte*
(plus facilement importable que le backup binaire) via un crontab :

    ejabberdctl dump backup-ejabberd-db

Ce fichier est généré dans /var/lib/ejabberd/. On pourrait l'exposer
via le serveur web avec un access restreint (`.htaccess`).

    mv /var/lib/ejabberd/backup-ejabberd-db /var/www/html/

Les serveurs de backup de la chaine peuvent avoir un crontab qui
récupère et ré-importe cette db tous les jours à genre 4h du mat.

    curl -u username:password http://babare.dynamic-dns.net/backup-ejabberd-db \
         > /var/lib/ejabberd/backup-ejabberd-db
    ejabberdctl load backup-ejabberd-db
    # eventuellement un restart de ejabberd ici, a tester.

Le problème de cette solution c'est que chaque serveur est
indépendant. Quand le maitre se remet a marcher les clients n'ont
aucune raison de fermer la connexion qu'ils utilisent. On peut se
trouver avec des utilisateurs sur plusieurs serveurs sans qu'aucun
état/communication ne soit partagés (les users appairaitrons en ligne
sur qu'un seul serveur à la fois). Bref bordel. A creuser.


## Certificat

On ne pourra jamais avoir de certificat valide sur un
dynamic-dns.net. Il faut passer a un vrai domaine. Je peux fournir un
sous-domaine de `b0.cx` (genre `chat.b0.cx`, `babar.b0.cx`,
`xmpp.b0.cx`, ...)

## Tests

### Créer un compte

    ejabberdctl register admin localhost super-pw-de-ouf

### Connection client

Pour tester je recommande le client console `mcabber` qui peut etre
installer sur la meme machine que le serveur.

[Tutorial](http://yeuxdelibad.net/Logiciel-libre/Tutoriels/Mcabber.html)

    mkdir ~/.mcabber
    chmod 0700 ~/.mcabber

    # config par default (ca montre les options avec explications)
    cp /usr/share/doc/mcabber/examples/mcabberrc.example.gz ~/.mcabber/mcabberrc.gz
    gunzip ~/.mcabber/mcabberrc.gz

    # ou bien config a la zob du repo (ce que j'ai apres avoir enlever
    # tout les commentaires de la conf d'example et changer 2/3 trucs)
    cp mcabberrc ~/.mcabber/

    # edition de la config (changer jid, server, etc)
    $EDITOR ~/.mcabber/mcabberrc

Ne pas oublier de creer l'utilisateur ! (voir plus haut)

### DNS

Il peut etre utile de forcer `babare.dynamic-dns.net` à pointer sur la
boucle locale pour faire divers tests (ne marche que sur le serveur
évidemment...) :

    echo -e '127.0.0.1\tbabare.dynamic-dns.net' >> /etc/hosts
