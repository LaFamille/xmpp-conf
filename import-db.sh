#!/bin/bash

set -e

source ./utils.sh

tmpdb=last_master_db

mkdir -p $backup_dir/master
rsync -rtlz $master_user@$master_host:$backup_dir $backup_dir/master

cp $backup_dir/master/$backup_base $ejabberd_dir/$tmpdb
ejabberdctl stop
ejabberdctl load $tmpdb
ejabberdctl start

rm_old_files $backup_keep_last $backup_dir/$backup_base.*
