#!/bin/bash

# Run by postgres user

USER=replicator
# User with which we take the physical backup
PORT=5432
# Connection port to the server
PATRONI_YAML_PATH=/etc/patroni.yml
export PGPASSWORD=`cat $(cat ${PATRONI_YAML_PATH} | grep pgpass | cut -d':' -f2) | grep repl | rev | cut -d ':' -f1 | rev`
# Env variable for pg password. The password is extracted from the password file which is automatically created and 
# updated by Patroni


PG_LOCAL_FULL_BACKUP_DIR=/var/postgresql/pg-local-full-backup/systemd/
# Full backup root directory on a locally mounted drive (DAS)
PG_FULL_BACKUP_DIR=/backup/postgresql/pg-full-backup/systemd/
# Directory on a remote location to copy the full backups to
PG_FULL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-full-backup-archive/systemd/
# Conventionally tape archive of the backups which has its own retention policies
TIMESTAMP=$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S)
BACKUP_DIR=$PG_LOCAL_FULL_BACKUP_DIR$TIMESTAMP
# This backup local specific directory with the current timestamp.


# Starting the body of the script:

(! [ -z $PATRONI_YAML_PATH ] && ! [ -z $USER ] && ! [ -z $PORT ] && \
! [ -z $PG_LOCAL_FULL_BACKUP_DIR ] && ! [ -z $PG_FULL_BACKUP_DIR ] && \
! [ -z $PG_FULL_BACKUP_ARCHIVE_DIR ]) || \
{ echo "At least one variable is not assigned a value to. Check your variables." >&2; exit 1; }
# Exit the script if any of the variables are not assigned a value to.

set -o xtrace



if [ $(ip -4 addr show $(ip -br link | awk '$1 != "lo" {print $1}' | tail -1) | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | wc -l) -ne 2 ]; then
	echo "Backup process was skipped because this is not the primary replica."
	exit 0
fi
# Full backup will be only taken from the primary replica in a replication cluster according to the policies. A secondary replica however can
# also be manually specified.

mkdir -p $PG_LOCAL_FULL_BACKUP_DIR && sudo chown -R postgres:postgres $PG_LOCAL_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_ARCHIVE_DIR




/usr/bin/pg_basebackup -h vip -p $PORT -U $USER -w -D $BACKUP_DIR  -Ft -z -Xs -P;
# Backup statement

if [ $? -eq 0 ]; then
	echo "Backup process finished successfully."
else
	echo "Backup process failed."
	exit 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	
	
#cp -rf "$(find ${BACKUP_DIR} -maxdepth 1 -type d -exec ls -t {} + | head -1)" $PG_FULL_BACKUP_DIR	
cp -rf "${BACKUP_DIR}" $PG_FULL_BACKUP_DIR
# Copy from the local to the remote backup

if [ $? -eq 0 ]; then
	echo "Copy the backup to the remote location finished successfully."
else
	echo "Copy the backup to the remote location failed."
	exit 1
	# On the condition of the backup copy to the remote location failure, the purging operation
	# will be skipped and the service will also be marked as failed for this run.
fi	

cp -rf "$PG_FULL_BACKUP_DIR""$(find ${PG_FULL_BACKUP_DIR} -maxdepth 0 -type d -exec ls -t {} + | head -1)" \
$PG_FULL_BACKUP_ARCHIVE_DIR	
# Copy from the remote backup to the remote backup archive.


find $PG_LOCAL_FULL_BACKUP_DIR -mtime +2 -type d -exec rm -rf {} \;
find $PG_FULL_BACKUP_DIR -mtime +15 -type d -exec rm -rf {} \;
find $PG_FULL_BACKUP_ARCHIVE_DIR -mtime +15 -type f -exec rm -f {} \;
# purging operation
