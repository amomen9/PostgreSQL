# simple systemd Backup Automation (A typical cluster like Patroni with a VIP)


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
mkdir -p /var/lib/postgresql/scripts
chown -R postgres:postgres /var/lib/postgresql/scripts

mkdir -p /archive/postgresql/pg-wal-archive/
mkdir -p /archive/postgresql/pg-local-full-backup/systemd/
chown -R postgres:postgres /archive/postgresql
```

### 2. [X] **Scripts**

List of scripts:

|<div align="left">pg_wal_backup.sh<br/>pg_full_backup.sh</div>|
|:-:|

* **Note**: The scripts will be placed under `/var/lib/postgresql/scripts/ directory`.
1. WAL Backup & Purge Script (pg_wal_backup.sh)
<br/>

`pg_wal_backup.sh`:

```shell
#!/bin/bash
# PostgreSQL WAL Archiving Script
set -euo pipefail




# ----------- Custom Variables -------------
# All directory path values must end with /
PG_WAL_BACKUP_ARCHIVE_ROOT_DIR=/backup/Backups/postgresql/pg-wal-backup-archive/systemd/
# Directory where backups are to be copied

PG_WAL_ARCHIVE_DIR=/archive/postgresql/pg-wal-archive/
# The directory where PostgreSQL DB Cluster copies the generated WAL files for archiving.
# Note: Every node in a clustered replication generates its own WAL files, and thus we will
# have # of nodes backup archives.
MAX_LOG_SIZE=$((100*1024*1024))  # 100MB in bytes, Custom maximum allowed size for the log file
# ------------------------------------------


# ---------- Calculated Variables ---------
INSTANCE=$(yq eval '.scope' /etc/patroni/config.yml)
PG_WAL_BACKUP_ARCHIVE_DIR="$PG_WAL_BACKUP_ARCHIVE_ROOT_DIR""$(hostname)/"
LOG_FILE="/var/log/postgresql/pg_wal_backup_${INSTANCE}.log"
OVERALL_RESULT=0
CMDOUT=""
CURRENT_LOG_SIZE=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
# -----------------------------------------


# Functions ---------------------------------------------------------------
# TIMESTAMP function
get_TIMESTAMP() {
	echo $(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N)
}

# Log function
log() {
  if [ $# -eq 0 ]; then
	echo >> "$LOG_FILE"; 
  else  
	echo "$(get_TIMESTAMP) - $INSTANCE: $@" >> "$LOG_FILE";
  fi
}

# Exit script
exitscript() {
	if [ $1 -gt 0 ]; then log "Warning! Some operation(s) failed but the main backup succeeded. Take necessary actions manually"; fi
	log "-------------------------------------- Ended -------------------------------------------"
	log
	log
	log
	echo -e "---\nFor more details go to the log file."
	echo "-------------------------------------- Ended -------------------------------------------"
	exit $1
}

# Multiple commands exit code check
run_command() {
    CMDOUT="$CMDOUT$("$@" 2>&1)"
    if [ $? -ne 0 ]; then
        OVERALL_RESULT=1
    fi
}
# -------------------------------------------------------------------------




# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p $PG_WAL_BACKUP_ARCHIVE_DIR




if [ "$CURRENT_LOG_SIZE" -gt "$MAX_LOG_SIZE" ]; then
    > "$LOG_FILE"
    echo "Truncated $LOG_FILE (was ${CURRENT_LOG_SIZE} bytes)"
fi



log "------------------------------------- Started ------------------------------------------"
log "Starting WAL archiving ..."
echo
echo
echo "------------------------------------- Started ------------------------------------------"
echo "Starting WAL archiving ..."
echo "LOG file path: $LOG_FILE"




CMDOUT=""
OVERALL_RESULT=0
# Archive all pending WAL files
wal_files_found=0
for wal_file in $(find "$PG_WAL_ARCHIVE_DIR" -type f -name "000000*" 2>/dev/null); do
  wal_files_found=1
  wal_name=$(basename "$wal_file")
  log "Archiving $wal_name ..."
  run_command timeout 1m mv "$wal_file" "$PG_WAL_BACKUP_ARCHIVE_DIR"
done

if [ "$wal_files_found" -eq 0 ]; then
  log "Warning! No WAL files were found to backup"
  echo "Warning! No WAL files were found to backup"
  exitscript 0
fi


if [ $OVERALL_RESULT -eq 0 ]; then
	log "Copy all WAL files completed successfully."
	echo "Copy all WAL files completed successfully."
	exitscript 0
	#echo "Copy full backup to remote tape storage finished successfully."
else
	log "Copy some WAL files failed. MSG: "$CMDOUT
	echo "Copy some WAL files failed."
	exitscript 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	



timeout 1h find $PG_WAL_BACKUP_ARCHIVE_DIR -maxdepth 1 -type f -mtime +10 -print0 | xargs -0 -r rm -rf


log "WAL archiving completed successfully."
exitscript 0







```

2. Full Backup & Purge Script (pg_full_backup.sh)
<br/>

* Install YAML query tool `yq` as a prerequisite:
```shell
sudo snap install yq
```

If you cannot use snap package manager, you can download the binary directly from its official github page.
 The URL is something like:
 
```shell
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
```
Then:
```shell
sudo chmod +x /usr/bin/yq
```

If you cannot use snap package manager on your server, you can install `yq` on a third Ubuntu server and simply transfer
a single yq's binary to your server and <ins>add it to the path</ins>.

`pg_full_backup.sh`:

```shell
#!/bin/bash
# PostgreSQL Full Backup Script
set -euo pipefail


# ----------- Custom Variables -------------
# All directory path values must end with /
LOG_FILE_DIRECTORY="/var/log/postgresql/"
PATRONI_YAML_PATH=/etc/patroni/config.yml
VIP_MANAGER_YAML_PATH=/etc/default/vip-manager.yml
PG_LOCAL_FULL_BACKUP_DIR=/archive/postgresql/pg-local-full-backup/systemd/
# Full backup root directory on a locally mounted drive (DAS)
PG_FULL_BACKUP_DIR=/backup/Backups/postgresql/pg-full-backup/systemd/
# Directory on a remote location to copy the full backups to
PG_FULL_BACKUP_TAPE_DIR=/backup/TapeBackups/postgresql/pg-full-backup-archive/systemd/
# Conventionally tape archive of the backups which has its own retention policies
BACKUP_TIMEOUT_DURATION="24h"  # Set your timeout duration (e.g., 1h, 30m, 3600s)
BACKUP_TYPE=Full	# Full/Incremental
BACKUP_COMPRESSION_LEVEL="1"
# -----------------------------------------


# Functions -------------------------------
# TIMESTAMP function
get_TIMESTAMP() {
	echo $(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N)
}

# Log function
log() {
  if [ $# -eq 0 ]; then
	echo >> "$LOG_FILE"; 
  else  
	echo "$(get_TIMESTAMP) - $INSTANCE: $@" >> "$LOG_FILE";
  fi
}

# Exit script
exitscript() {
	if [ $1 -gt 0 ]; then log "Warning! Some operation(s) failed but the main backup succeeded. Take necessary actions manually"; fi
	log "-------------------------------------- Ended -------------------------------------------"
	log
	log
	log
	echo -e "---\nFor more details go to the log file."
	echo "-------------------------------------- Ended -------------------------------------------"
	exit $1
}


# Multiple commands exit code check
run_command() {
    CMDOUT="("$@" 2>&1)" 2>&1
    if [ $? -ne 0 ]; then
        OVERALL_RESULT=1
    fi
}
# -----------------------------------------


# ---------- Calculated Variables ---------
INSTANCE=$(yq eval '.scope' /etc/patroni/config.yml)
LOG_FILE="${LOG_FILE_DIRECTORY}""pg_full_backup_${INSTANCE}.log"
START_TIMESTAMP=$(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S)
OVERALL_RESULT=0
CMDOUT=""
BACKUP_DIR=$PG_LOCAL_FULL_BACKUP_DIR$(get_TIMESTAMP)"/"
# This backup's local specific directory with the current timestamp.
# -----------------------------------------


# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"


MAX_SIZE=$((100*1024*1024))  # 100MB in bytes
current_size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)

if [ "$current_size" -gt "$MAX_SIZE" ]; then
    > "$LOG_FILE"
    echo "Truncated $LOG_FILE (was ${current_size} bytes)"
fi



log "------------------------------------- Started ------------------------------------------"
log "Starting Full Backup ..."
echo
echo
echo "------------------------------------- Started ------------------------------------------"
echo "Starting Full Backup ..."
echo "LOG file path: $LOG_FILE"


#-------------PG Variables -------------------------------------------------
export PGHOST=$(yq eval '.ip' "$VIP_MANAGER_YAML_PATH")
# Host to take the backup from

export PGUSER=$(yq e '.postgresql.authentication.replication.username' "$PATRONI_YAML_PATH")
# User with which we take the physical backup
export PORT=5432
# Connection port to the server
export PGPASSWORD=$(yq e '.postgresql.authentication.replication.password' "$PATRONI_YAML_PATH")
# Env variable for pg password. The password is extracted from the password file which is automatically created and 
# updated by Patroni


#----------------------------------------------------------------------------
# Starting the body of the script:

(! [ -z $PATRONI_YAML_PATH ] && ! [ -z $USER ] && ! [ -z $PORT ] && \
! [ -z $PG_LOCAL_FULL_BACKUP_DIR ] && ! [ -z $PG_FULL_BACKUP_DIR ] && \
! [ -z $PG_FULL_BACKUP_TAPE_DIR ]) || \
{ echo "At least one variable is not assigned a value to. Check your variables." >&2; exitscript 1; }
# Exit the script if any of the variables are not assigned a value to.




if [ $(ip -4 addr show $(ip -br link | awk '$1 != "lo" {print $1}' | tail -1) | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | wc -l) -ne 2 ]; then
	echo "Warning! Exiting: $BACKUP_TYPE backup process was skipped because this is not the primary replica."
	exitscript 0
fi
# Full backup will be only taken from the primary replica in a replication cluster according to the policies. A secondary replica however can
# also be manually specified.

mkdir -p $PG_LOCAL_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_DIR


mkdir -p $PG_FULL_BACKUP_TAPE_DIR


#-------------------------- Backup process start: ------------------------------------
#CMDOUT=$(time /usr/bin/pg_basebackup -p $PORT -w -c fast -D $BACKUP_DIR -Ft -z -Z 1 -Xs 2>&1)


# Initialize duration with default value
duration="00:00:00:00.000"

# Create temporary file
temp_out=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

# Run command with timing
start_time=$(date +%s.%N) || start_time=$(date +%s) # Fallback to seconds precision
set +e

###### ------------------ Backup command --------------------
timeout $BACKUP_TIMEOUT_DURATION /usr/bin/pg_basebackup -p $PORT -w -c fast -D $BACKUP_DIR -Ft -z -Z $BACKUP_COMPRESSION_LEVEL -Xs > "$temp_out" 2>&1
###### ------------------------------------------------------

exit_code=$?
set -e
end_time=$(date +%s.%N) || end_time=$(date +%s) # Fallback to seconds precision

if [ -e "$BACKUP_DIR" ] || [ -L "$BACKUP_DIR" ]; then
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    [ -z "$BACKUP_SIZE" ] && BACKUP_SIZE=$(ls -lh "$BACKUP_DIR" 2>/dev/null | awk '{print $5}')
else
    BACKUP_SIZE=""
fi

# Read command output safely
CMDOUT=$(cat "$temp_out" 2>/dev/null || echo "Failed to read command output")
rm -f "$temp_out"

# Calculate duration safely
elapsed=$(echo "$end_time - $start_time" 2>/dev/null | bc) || elapsed=0

# Calculate time components with error handling
if [[ $(echo "$elapsed > 0" | bc) -eq 1 ]]; then
    full_seconds=$(printf "%.0f" "$elapsed" 2>/dev/null) || full_seconds=0
    milliseconds=$(printf "%.0f" "$(echo "($elapsed - $full_seconds)*1000" | bc)" 2>/dev/null) || milliseconds=0
    milliseconds=$(( milliseconds < 0 ? 0 : milliseconds ))
    # Ensure milliseconds is 3 digits
    milliseconds=$(printf "%03d" "$milliseconds" 2>/dev/null) || milliseconds=000

    seconds=$((full_seconds % 60))
    minutes=$(( (full_seconds / 60) % 60 ))
    hours=$(( (full_seconds / 3600) % 24 ))
    days=$(( full_seconds / 86400 ))

    duration=$(printf "%02d:%02d:%02d:%02d.%03d" "$days" "$hours" "$minutes" "$seconds" "$milliseconds" 2>/dev/null) || duration="00:00:00:00.000"
fi


# Format the output based on success/failure
if [ $exit_code -eq 0 ]; then
    echo "$BACKUP_TYPE backup completed successfully."
    echo "Duration: $duration (DD:HH:MM:SS)"
    echo "Backup size: $BACKUP_SIZE"
    log "$BACKUP_TYPE backup completed successfully."
    log "Duration: $duration (DD:HH:MM:SS)"
    log "Backup size: $BACKUP_SIZE"
else
	echo -n "Critical error! "
	echo "$BACKUP_TYPE backup was interrupted and failed for the following reason:"
	log "Critical error! "
	log "$BACKUP_TYPE backup was interrupted and failed for the following reason:"
	if [ $exit_code -eq 124 ]; then
		CMDOUT="The user defined timeout exceeded (Exit code 124)";
	fi
	echo "$CMDOUT"
	echo "Duration: $duration (DD:HH:MM:SS)"
	echo "Leftovers size on disk: $BACKUP_SIZE"
	log "$CMDOUT"
	log "Duration: $duration (DD:HH:MM:SS)"
	log "Leftovers size on disk: $BACKUP_SIZE"
	exitscript -1
fi


#-------------------------- Backup process end------------------------------------


#-------------------------- Copy to remote location ------------------------------	
#cp -rf "$(find ${BACKUP_DIR} -maxdepth 1 -type d -exec ls -t {} + | head -1)" $PG_FULL_BACKUP_DIR	
CMDOUT=$(timeout 24h cp -rf "${BACKUP_DIR}" $PG_FULL_BACKUP_DIR 2>&1)
# Copy from the local to the remote backup

if [ $? -eq 0 ]; then
	log "Copy $BACKUP_TYPE backup to remote storage finished successfully."
	echo "Copy $BACKUP_TYPE backup to remote storage finished successfully."
else
	log "Copy $BACKUP_TYPE backup to remote storage failed. MSG: $CMDOUT"
	exitscript 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	
#---------------------------------------------------------------------------------

#-------------------------- Copy to tape remote location -------------------------
#set -x
CMDOUT=$(timeout 24h cp -rf "${PG_FULL_BACKUP_DIR}""$(basename ${BACKUP_DIR})" \
$PG_FULL_BACKUP_TAPE_DIR) 2>&1	
# set +x

if [ $? -eq 0 ]; then
	log "Copy $BACKUP_TYPE backup to remote --tape-- storage finished successfully."
	echo "Copy $BACKUP_TYPE backup to remote --tape-- storage finished successfully."
else
	log "Copy $BACKUP_TYPE backup to remote --tape-- storage failed. MSG: $CMDOUT"
	echo "Copy $BACKUP_TYPE backup to remote --tape-- storage failed. MSG: $CMDOUT"	
	exitscript 1
fi	
# Copy from the remote backup to the remote backup archive.
#---------------------------------------------------------------------------------


#---------------------------- Purge old backups ----------------------------------
# On the condition of the backup failure, the purging operation will be skipped and the
# service will also be marked as failed for this run.

CMDOUT=""
OVERALL_RESULT=0

# For local directory (fast filesystem)
run_command timeout 30m find "$PG_LOCAL_FULL_BACKUP_DIR" -maxdepth 1 -type d -mtime +2 -exec rm -rf {} +
echo "Purge local $BACKUP_TYPE backups: ${CMDOUT}"
log "Purge local $BACKUP_TYPE backups: ${CMDOUT}"

# For CIFS shares (slower network filesystems)
run_command timeout 1h find "$PG_FULL_BACKUP_DIR" -maxdepth 1 -type d -mtime +15 -print0 | xargs -0 -r rm -rf
echo "Purge remote $BACKUP_TYPE backups: ${CMDOUT}"
log "Purge remote $BACKUP_TYPE backups: ${CMDOUT}"

run_command timeout 1h find "$PG_FULL_BACKUP_TAPE_DIR" -maxdepth 1 -type d -mtime +15 -print0 | xargs -0 -r rm -rf
echo "Purge remote --tape-- $BACKUP_TYPE backups: ${CMDOUT}"
log "Purge remote --tape-- $BACKUP_TYPE backups: ${CMDOUT}"
# purging operation

if [ $OVERALL_RESULT -eq 0 ]; then
	log "Purging $BACKUP_TYPE backups completed successfully."
	echo "Purging $BACKUP_TYPE backups completed successfully."
	exitscript 0
	#echo "Copy full backup to remote tape storage finished successfully."
else
	log "Some purge $BACKUP_TYPE backup steps failed. MSG: $CMDOUT"
	echo "Some purge $BACKUP_TYPE backup steps failed. MSG: $CMDOUT"
	exitscript 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	
#---------------------------------------------------------------------------------


#---------------------------- Exit control ---------------------------------------
exitscript 0
#---------------------------------------------------------------------------------




```

### 3. [X] Service template

|<div align="left">Service Template: `PostgreSQL@.service`<br/>base backup: `PostgreSQL@pg_full_backup.service`<br/>WAL backup: `PostgreSQL@pg_wal_backup.service`</div>|
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
# After=postgresql@15-main.service
Wants=%I.timer

[Service]
Type=oneshot

User=postgres
Group=postgres

Environment=PGDATA=/var/lib/postgresql/15/main/
# pg data dir as an env variable for the service execution
Environment=SCHOME=/var/lib/postgresql/scripts/
WorkingDirectory=/var/lib/postgresql/scripts/

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

1. Timer to trigger WAL backup (pg_wal_backup.timer)

```shell

# This timer unit is for backing up WAL segments
#

[Unit]
Description=timer unit is for backing up WAL segments
Requires=PostgreSQL@pg_wal_backup.service

[Timer]
Unit=PostgreSQL@pg_wal_backup.service
OnCalendar=*-*-* *:00:00
# Every hour


[Install]
WantedBy=timers.target

```

2. Timer to trigger full backup (pg_full_backup.timer)

```shell
# This timer unit is for PostgreSQL base backup 
#

[Unit]
Description=This timer unit is for PostgreSQL base backup
Requires=PostgreSQL@pg_full_backup.service

[Timer]
Unit=PostgreSQL@pg_full_backup.service
OnCalendar=*-*-* 19:30:00
# Evert day at 19:30:00


[Install]
WantedBy=timers.target

```

### 5. [X] Activation
1. Place the service and timer files in the following directory using root privileges:
/lib/systemd/system/

2. Enable services
```shell
sudo systemctl enable PostgreSQL@pg_wal_backup.service
sudo systemctl enable PostgreSQL@pg_full_backup.service
```

3. Enable timers
```shell
sudo systemctl enable --now pg_wal_backup.timer
sudo systemctl enable --now pg_full_backup.timer
```

4. View the status of created and enabled units:
```shell
sudo systemctl status pg_wal_backup.timer
sudo systemctl status pg_full_backup.timer
sudo systemctl status PostgreSQL@pg_wal_backup.service
sudo systemctl status PostgreSQL@pg_full_backup.service
```

* Note: To manually take a full backup or archive WALs (for instance, in the event that there is a low disk space problem), you can simply execute their services and you do not need to manually write and execute the commands
`sudo systemctl start PostgreSQL@pg_wal_backup.service`
`sudo systemctl start PostgreSQL@pg_full_backup.service`



Finish ■
