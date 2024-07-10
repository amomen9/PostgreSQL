#!/bin/bash

PG_WAL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-wal-backup-archive/systemd/$(hostname)/
PG_WAL_ARCHIVE_DIR=/var/postgresql/pg-wal-archive/

mkdir -p $PG_WAL_BACKUP_ARCHIVE_DIR

tar cvf "$PG_WAL_BACKUP_ARCHIVE_DIR"pg-wal-backup-archive_`TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S`.tar "$PG_WAL_ARCHIVE_DIR"* # --remove-files

find $PG_WAL_BACKUP_ARCHIVE_DIR -mtime +10 -type f -exec rm -f {} \;
find $PG_WAL_ARCHIVE_DIR -mtime +4 -type f -exec rm -f {} \;
