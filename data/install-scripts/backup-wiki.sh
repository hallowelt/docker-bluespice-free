#!/bin/bash

echo "Old installation detected! Moving old installation to /data/backups/$date"
/etc/init.d/memcached start >> /data/logs/wiki.logs 2>&1
sleep 20
chown -Rf mysql:mysql /data/mysql
rm -Rf /var/lib/mysql >>/data/logs/wiki.logs 2>&1
ln -s /data/mysql /var/lib/mysql >>/data/logs/wiki.logs 2>&1
/etc/init.d/mysql start >> /data/logs/wiki.logs 2>&1
mkdir -p /data/backups/
mv /data/www/bluespice /data/backups/$date

if ! [ "$WIKI_BACKUP_LIMIT" -gt 0 ]; then
    WIKI_BACKUP_LIMIT=5
fi

WIKI_BACKUP_DIR="/data/www/backups"

all_backups=($(find "$WIKI_BACKUP_DIR" -maxdepth 1 -type d -exec basename {} \;))

if [ "${#all_backups[@]}" -gt "$WIKI_BACKUP_LIMIT" ]; then
    all_backups=($(for dir in "${all_backups[@]}"; do echo "$dir"; done | sort))
    rm -rf "$WIKI_BACKUP_DIR/${all_backups[0]}"
fi
# python3 $SCRIPT_DIR/backup-wiki-data.py $WIKI_BACKUP_LIMIT >>/data/logs/wiki.logs 2>&1