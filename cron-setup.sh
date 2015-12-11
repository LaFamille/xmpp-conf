#!/bin/bash

set -e

source ./utils.sh

check_if_root

usage() {
    die "Usage: $0 [slave|master] [install|remove]"
}

remove_backup_cron() {
    ( (crontab -l || true) | grep -v '##cron-setup' ) | crontab -
}

add_backup_cron() {
    ( (contab -l || true) ; echo "$@" "##cron-setup generated, leave this!" ) | crontab -
}

if [ $# -lt 2 ]; then
    usage
fi

mode=$1
op=$2
shift 2

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

case $mode in
    master) true;;
    slave) true;;
    *) usage;;
esac

case $op in
    install) true;;
    remove) true;;
    *) usage;;
esac

remove_backup_cron

# master backup at 4am
if [ $mode = "master" -a $op = "install" ]; then
    add_backup_cron "0 4 * * * cd $script_dir ; ./export-db.sh"

# slave import at 4:30am
if [ $mode = "slave" -a $op = "install" ]; then
    add_backup_cron "30 4 * * * cd $script_dir ; ./import-db.sh"
fi

