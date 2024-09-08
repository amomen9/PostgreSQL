# simple systemd Backup Automation (For pgPool Cluster with VIP)

The systemd backup automation plan is a simple plan composed of a service template with two 
 timers without any additional/external tools or extensions like Barman, pgagent, pg_cron, 
 etc. One of the timers triggers the service instance for compressing, backing up, and purging 
 the old WAL files. The other one triggers the same for full backups. The backups are created 
 in gzip format. The instantiated services run some scripts. All of them will be briefly explained below.


### 1. [X] **Create required directories**

You have to manually create one of the directories used in this document which is the following.
 The others either already exist or are created by the scripts automatically. If you need to change
 a directory, you might need to change it inside the scripts:

```shell
mkdir -p /data/postgresql/scripts
chown -R postgres:postgres /data/postgresql/scripts

mkdir -p /var/postgresql/pg-wal-archive/
mkdir -p /var/postgresql/pg-local-full-backup/systemd/
chown -R postgres:postgres /var/postgresql
```

### 2. [X] **Scripts**

List of scripts:

|<div align="left">archive_wal.sh<br/>postgres_backup.sh</div>|
|:-:|

* **Note**: The scripts will be placed under `/data/postgresql/scripts/ directory`.
1. WAL Backup & Purge Script (archive_wal.sh)
<br/>

```shell
#!/bin/bash

PG_WAL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-wal-backup-archive/systemd/$(hostname)/
# Directory where backups are to be copied

PG_WAL_ARCHIVE_DIR=/var/postgresql/pg-wal-archive/
# The directory where PostgreSQL DB Cluster copies the generated WAL files for archiving.
# Note: Every node in a clustered replication generates its own WAL files, and thus we will
# have # of nodes backup archives.


mkdir -p $PG_WAL_BACKUP_ARCHIVE_DIR

tar cvf "$PG_WAL_BACKUP_ARCHIVE_DIR"pg-wal-backup-archive_`TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S`.tar "$PG_WAL_ARCHIVE_DIR"* # --remove-files
# The tar command archives and compresses the WAL files existing in the PG_WAL_ARCHIVE_DIR directory.

find $PG_WAL_BACKUP_ARCHIVE_DIR -mtime +10 -type f -exec rm -f {} \;
find $PG_WAL_ARCHIVE_DIR -mtime +4 -type f -exec rm -f {} \;

```

2. Full Backup & Purge Script (postgres_backup.sh)
<br/>

```shell
#!/bin/bash

TIMESTAMP=$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S)
PG_LOCAL_FULL_BACKUP_DIR=/var/postgresql/pg-local-full-backup/systemd/
# Full backup root directory on a locally mounted drive (DAS)
PG_FULL_BACKUP_DIR=/backup/postgresql/pg-full-backup/systemd/
# Directory on a remote location to copy the full backups to
PG_FULL_BACKUP_ARCHIVE_DIR=/backup/postgresql/pg-full-backup-archive/systemd/
# Conventionally tape archive of the backups which has its own retension policies

BACKUP_DIR=$PG_LOCAL_FULL_BACKUP_DIR$TIMESTAMP
# This backup local specific directory with the current timestamp.

set -o xtrace


if [ $(ip -4 addr show $(ip -br link | awk '$1 != "lo" {print $1}' | tail -1) | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | wc -l) -ne 2 ]; then
	echo "Backup process was skipped because this is not the primary replica."
	exit 0
fi
# Full backup will be only taken from the primary replica in a replication cluster according to the policies. A secondary replica however can
# also be manually specified.

sudo mkdir -p $PG_LOCAL_FULL_BACKUP_DIR && sudo chown -R postgres:postgres $PG_LOCAL_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_ARCHIVE_DIR


PGPASSFILE="$(echo ~postgres)/.pgpass"
# Env variable for .pgpass file path

/usr/bin/pg_basebackup -h vip -p 5432 -U pgpool -w -D $BACKUP_DIR  -Ft -z -Xs -P;
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
```

### 3. [X] Service template

|<div align="left">Service Template: `PostgreSQL@.service`<br/>base backup: `PostgreSQL@postgres_backup.service`<br/>WAL backup: `PostgreSQL@archive_wal.service`</div>|
|:-:|

The following is the `PostgreSQL@.service` service template which is used to execute the above scripts on a regular basis. For more details regarding services, service templates, timers, and their schedules refer to the link to a short article about this below:

[https://github.com/amomen9/Linux/tree/main/Systemd%20Service%20and%20Timer](https://github.com/amomen9/Linux/tree/main/Systemd%20Service%20and%20Timer)

```shell
# /etc/systemd/system/pgbt.service

[Unit]
Description=PG maintenace task service triggered by timer
#Documentation='No documentation for now'
After=syslog.target
After=network.target
After=multi-user.target
After=postgresql@15-main.service
Wants=%I.timer

[Service]
Type=oneshot

User=postgres
Group=postgres

Environment=PGDATA=/data/postgresql/15/main/data/
# pg data dir as an env variable for the service execution
Environment=SCHOME=/data/postgresql/scripts/
WorkingDirectory=/data/postgresql/scripts/

# Where to send early-startup messages from the server
# This is normally controlled by the global default set by systemd
# StandardOutput=syslog


OOMScoreAdjust=-1000
Environment=PGB_OOM_ADJUST_FILE=/proc/self/oom_score_adj
Environment=PGB_OOM_ADJUST_VALUE=0
# Disable OOM kill on the service to increase its resilience.


ExecStart=/bin/nohup ./%I.sh


[Install]
WantedBy=multi-user.target

```

### 4. [X] Timers

1. Timer to trigger WAL backup (archive_wal.timer)

```shell

# This timer unit is for backing up WAL segments
#

[Unit]
Description=timer unit is for backing up WAL segments
Requires=PostgreSQL@archive_wal.service

[Timer]
Unit=PostgreSQL@archive_wal.service
OnCalendar=*-*-* *:00:00
# Every hour


[Install]
WantedBy=timers.target

```

2. Timer to trigger full backup (postgres_backup.timer)

```shell
# This timer unit is for PostgreSQL base backup 
#

[Unit]
Description=This timer unit is for PostgreSQL base backup
Requires=PostgreSQL@postgres_backup.service

[Timer]
Unit=PostgreSQL@postgres_backup.service
OnCalendar=*-*-* 19:30:00
# Evert day at 19:30:00


[Install]
WantedBy=timers.target

```

### 5. [X] Activation
1. Place the service and timer files in the following directory using root privileges:
/lib/systemd/system/

2. enable services
```shell
sudo systemctl enable PostgreSQL@archive_wal.service
sudo systemctl enable PostgreSQL@postgres_backup.service
```

3. enable timers
```shell
sudo systemctl enable --now archive_wal.timer
sudo systemctl enable --now postgres_backup.timer
```


Finish ■