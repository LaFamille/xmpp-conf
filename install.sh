#!/bin/bash

# exit on errors
set -e

source ./utils.sh

check_if_root

is_master_node=

if [ "$1" = "master" ]; then
    is_master_node=true
elif [ "$1" = "slave" ]; then
    is_master_node=false
else
    die "Usage: $0 [master|slave]"
fi

if ! which sshd; then
    msg "inital packages installation"
    apt-get update
    apt-get install openssh-server
fi

if ! which sudo; then
    msg "installing sudo"
    apt-get install sudo
fi

if ! $is_master_node; then
    if ! stat ~/.ssh/id_rsa.pub &> /dev/null; then
	msg "couldnt find an existing ssh key; generating one"
	ssh-keygen
    fi

    msg "ask for your public key (~$USER/.ssh/id_rsa.pub) to be added to the master user"
    msg "authorized keys (~$master_user/.ssh/autorized_keys)"
    msg "echo '"$(cat ~/.ssh/id_rsa.pub)"' >> ~$master_user/.ssh/authorized_keys"

    while true; do
	msg "testing master access..."
	if ! ssh $master_user@$master_host true; then
	    msg "press return to try again..."
	    read line
	else
	    if ! yn "something asked to you?"; then
		break
	    fi
	fi
    done
    msg "yay, ssh access seems to work"
fi

msg "package installation"
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
    if [ -e /var/www/html/chat/ ] && yn "remove old web root that looks like previous setup?"; then
	rm -rf /var/www/html
    else
	newr="/var/www/html.bak.$(date +%Y-%m-%d-%H:%M:%S)"
	mv /var/www/html "$newr"
	msg "backup web old web root to $newr"
    fi
fi
cp -R apache/webroot /var/www/html

msg "redirecting port 110 to xmpp server port 5222"
iptables -t nat -A PREROUTING -p tcp --dport 110 -j REDIRECT --to-port 5222
iptables-save > /etc/iptables/rules.v4

if $is_master_node; then
    msg "creating backup user (used by slaves)"
    if ! user_exists $master_user; then
	useradd -m -g ejabberd $master_user
    fi
    sudo -u $master_user bash -c 'mkdir -p ~/.ssh ; chmod 0700 ~/.ssh ; cd ~/.ssh ; touch authorized_keys ; chmod 0600 authorized_keys'
    chmod -R g+rwx $ejabberd_dir
    msg "all done!"
else
    msg "almost done! add this host the the DNS zone file, see http://wiki.xmpp.org/web/SRV_Records#Example_3"
fi
