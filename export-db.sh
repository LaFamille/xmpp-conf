#!/bin/bash

set -e

source ./utils.sh

# backup name
full=$(backup_new_file)

ejabberdctl dump $full
mkdir -p $backup_dir
mv /var/lib/ejabberd/$full $backup_dir
ln -rs $backup_dir/$full $backup_dir/$backup_base-new
mv $backup_dir/$backup_base-new $backup_dir/$backup_base

rm_old_files $backup_keep_last $backup_dir/$backup_base.*

