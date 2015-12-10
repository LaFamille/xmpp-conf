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

En cours.
