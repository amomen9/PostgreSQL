#!/bin/bash

PG_WAL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-wal-backup-archive/systemd/$(hostname)/	
# Directory where backups are to be copied
PG_WAL_ARCHIVE_DIR=/var/postgresql/pg-wal-archive/
# The directory where PostgreSQL DB Cluster copies the generated WAL files for archiving.
# Note: Every node in a clustered replication generates its own WAL files, and thus we will
# have # of nodes backup archives.


mkdir -p $PG_WAL_BACKUP_ARCHIVE_DIR

tar cvf "$PG_WAL_BACKUP_ARCHIVE_DIR"pg-wal-backup-archive_`TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S`.tar \
"$PG_WAL_ARCHIVE_DIR"* # --remove-files
# The tar command archives and compresses the WAL files existing in the PG_WAL_ARCHIVE_DIR directory.

find $PG_WAL_BACKUP_ARCHIVE_DIR -mtime +10 -type f -exec rm -f {} \;
# Once the retention policies for the backups are considered, the older backups will be purged accordingly.
# The retention time will be defined by the -mtime parameter. Ex: -mtime +10 means older than
# 10 days. 

find $PG_WAL_ARCHIVE_DIR -mtime +4 -type f -exec rm -f {} \;