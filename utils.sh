#!/bin/bash

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

check_if_root() {
    if [ "$EUID" -ne 0 ]; then
	die "run as root please"
    fi
}

yn() {
    while true; do
	read -p "$*" yn
	case $yn in
	    [Yy]* ) return 0;;
	    [Nn]* ) return 1;;
	    * ) echo "please answer yes or no.";;
	esac
    done
}


backup_base=ejabberd-backup
backup_date_format="+%Y-%m-%d" # max 1 backup per day

backup_new_file() {
    echo $backup_base.$(date $backup_date_format)
}

rm_old_files() {
    local n=$1
    shift
    ls -t "$@" | sed 1,${n}d | xargs rm -f
}

# place where ejabberctl looks for
ejabberd_dir=/var/ejabberd

# place to store master backups
backup_dir=/var/ejabberd/backup

# nb of backup file to keep
backup_keep_last=5

master_user=xmppbackup
master_host=babare.dynamic-dns.net
