#!/bin/bash
TIMESTAMP=$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S)
PG_LOCAL_FULL_BACKUP_DIR=/var/postgresql/pg-local-full-backup/systemd/
PG_FULL_BACKUP_DIR=/backup/postgresql/pg-full-backup/systemd/
PG_FULL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-full-backup-archive/systemd/

BACKUP_DIR=$PG_LOCAL_FULL_BACKUP_DIR$TIMESTAMP

set -o xtrace


if [ $(ip -4 addr show $(ip -br link | awk '$1 != "lo" {print $1}' | tail -1) | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | wc -l) -ne 2 ]; then
	echo "Backup process was skipped because this is not the primary replica."
	exit 0
fi


sudo mkdir -p $PG_LOCAL_FULL_BACKUP_DIR && sudo chown -R postgres:postgres $PG_LOCAL_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_ARCHIVE_DIR


PGPASSFILE="$(echo ~postgres)/.pgpass"

/usr/bin/pg_basebackup -h vip -p 5432 -U pgpool -w -D $BACKUP_DIR  -Ft -z -Xs -P;

if [ $? -eq 0 ]; then
	echo "Backup process finished successfully."
else
	echo "Backup process failed."
	exit 1
fi	
	
#cp -rf "$(find ${BACKUP_DIR} -maxdepth 1 -type d -exec ls -t {} + | head -1)" $PG_FULL_BACKUP_DIR	
cp -rf "${BACKUP_DIR}" $PG_FULL_BACKUP_DIR	

if [ $? -eq 0 ]; then
	echo "Copy the backup to the remote location finished successfully."
else
	echo "Copy the backup to the remote location failed."
	exit 1
fi	

cp -rf "$PG_FULL_BACKUP_DIR""$(find ${PG_FULL_BACKUP_DIR} -maxdepth 0 -type d -exec ls -t {} + | head -1)" \
$PG_FULL_BACKUP_ARCHIVE_DIR	



find $PG_LOCAL_FULL_BACKUP_DIR -mtime +2 -type d -exec rm -rf {} \;
find $PG_FULL_BACKUP_DIR -mtime +15 -type d -exec rm -rf {} \;
find $PG_FULL_BACKUP_ARCHIVE_DIR -mtime +15 -type f -exec rm -f {} \;
