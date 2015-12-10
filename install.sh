#!/bin/bash

# exit on errors
set -e

die() {
    echo -e "\033[1;31m[ERR] \033[0m\033[1m$*\033[0m"
    exit 1
}

msg() {
    echo -e "\033[1;32m[*] \033[0m\033[1m$*\033[0m"
}

cpbak() {
    cp --backup=simple --suffix=.bak $@
}

pkg_exists() {
    if apt-cache show "$1" &> /dev/null; then
	return 0
    else
	return 1
    fi
}

if [ "$EUID" -ne 0 ]; then
    die "run as root please"
fi

msg "packages installation"
apt-get update
apt-get install ejabberd apache2 iptables-persistent

if pkg_exists libapache2-mod-proxy-html; then
    apt-get install libapache2-mod-proxy-html
fi

msg "installing /etc/ejabberd/ejabberd.yml"
cpbak ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml

ejabberdctl restart

msg "installing apache2 site conf"
cpbak apache/xmpp-web.conf /etc/apache2/sites-available/

msg "enabling apache2 required modules"
a2enmod proxy_http
a2enmod proxy_html
service apache2 restart

msg "enabling reverse proxy front-end conf"
a2ensite xmpp-web
service apache2 restart

msg "installing website content"
# backup any existing web dir
if [ -e /var/www/html ]; then
    mv /var/www/html{,.bak}
fi
cp -R apache/webroot /var/www/html

msg "redirecting port 110 to xmpp server port 5222"
iptables -t nat -A PREROUTING -p tcp --dport 110 -j REDIRECT --to-port 5222
iptables-save > /etc/iptables/rules.v4

msg "all done!"
