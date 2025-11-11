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
PG_FULL_BACKUP_ARCHIVE_DIR=/backup/TapeBackups/postgresql/pg-full-backup-tape/systemd/
# Conventionally tape archive of the backups which has its own retention policies
BACKUP_TIMEOUT_DURATION="infinity"  # Set your timeout duration (e.g., 1h, 30m, 3600s)
BACKUP_TYPE=Full	# Full/Incremental
BACKUP_COMPRESSION_LEVEL="1"  # Compression level for pg_basebackup (0-9)
# 0 = no compression, 1 = fastest, 9 = best compression
STAT_PERCENTAGE=10 # Percentage of the backup completion to log progress for

# -----------------------------------------


# Functions -------------------------------
# TIMESTAMP function
get_TIMESTAMP() {
	echo $(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N)
}

# Log function
log() {
    local add_newline=false
    local interpret_escapes=false
    local include_timestamp=true          # --no-ts turns this off
    local message_content=""
    local message=""
    local timestamp
    timestamp=$(get_TIMESTAMP 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')

    if [ $# -gt 0 ]; then
        # Parse flags until first non-flag or explicit '--'
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --) shift; break ;;
                -[nc]*)
                    [[ "$1" == *n* ]] && add_newline=true
                    [[ "$1" == *c* ]] && interpret_escapes=true
                    shift
                    ;;
                --no-ts)
                    include_timestamp=false
                    shift
                    ;;
                *) break ;;
            esac
        done
        # Remaining args (if any) = message
        if [[ $# -gt 0 ]]; then
            message_content="$*"
        fi
    else
        add_newline=true
    fi

    # Build message
    if [[ -z "$message_content" ]]; then
        message=""
    else
        if $include_timestamp; then
            message="$timestamp - ${INSTANCE:-UNKNOWN}: $message_content"
        else
            message="$message_content"
        fi
    fi

    # Output (with or without escapes / newline)
    if $interpret_escapes; then
        if $add_newline; then
            echo -e "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2; return 2; }
        else
            echo -ne "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2; return 2; }
        fi
    else
        if $add_newline; then
            echo "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2; return 2; }
        else
            printf "%s" "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2; return 2; }
        fi
    fi
}
# Usage examples:
# log "Normal message"
# log -n "Message with newline flag"
# log --no-ts "Message without timestamp"
# log --no-ts -n -c "Escapes allowed, newline, no timestamp: Line1\nLine2"





calculate_elapsed_formatted() {

end_time=$(date +%s.%N) || end_time=$(date +%s) # Fallback to seconds precision
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

}


# Multiple commands exit code check
run_command() {
    # Accept full command string (including pipelines) as one argument
    local cmd="$*"
    local tmpfile status
    tmpfile=$(mktemp) || { echo "mktemp failed" >&2; OVERALL_RESULT=1; return 1; }

    # Use bash -c with pipefail so pipeline failures are caught
    bash -o pipefail -c "$cmd" >"$tmpfile" 2>&1
    status=$?

    (( status != 0 )) && OVERALL_RESULT=1
    CMDOUT=$(sed 's/\x0//g' "$tmpfile")
    rm -f "$tmpfile"
    return $status
}


# Exit script
exitscript() {
	#echo "Distinct list of errors: \n---------"
	#echo "$CUMULATIVE_COMMAND_OUTPUT\n---------"
	calculate_elapsed_formatted
	echo "---"$'\n'"Total Duration: $duration (DD:HH:MM:SS)"
	log -n "---"
	log -n "Duration: $duration (DD:HH:MM:SS)"


	if [ $# -eq 0 ]; then
		log "-------------------------------------- Ended -------------------------------------------";
		echo "-------------------------------------- Ended -------------------------------------------"
		log;
		log;
		log;	
		exit 0;
	fi
	
	if [ $1 -gt 0 ]; then log "Warning! Some operation(s) failed but the main backup succeeded. Take necessary actions manually"; fi
	
	log "-------------------------------------- Ended -------------------------------------------"
	log
	log
	log
	echo -e "---\nFor more details go to the log file."
	echo "-------------------------------------- Ended -------------------------------------------"
	
	exit $1
	
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
# ---------- Create directories -----------
mkdir -p 	$BACKUP_DIR \
			$LOG_FILE_DIRECTORY \
			$PG_LOCAL_FULL_BACKUP_DIR \
			$PG_FULL_BACKUP_DIR \
			$PG_FULL_BACKUP_ARCHIVE_DIR \
			"$(dirname "$LOG_FILE")"
#------------------------------------------




MAX_SIZE=$((100*1024*1024))  # 100MB in bytes
current_size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)

if [ "$current_size" -gt "$MAX_SIZE" ]; then
    > "$LOG_FILE"
    echo "Truncated $LOG_FILE (was ${current_size} bytes)"
fi



log -n "------------------------------------- Started ------------------------------------------"
log -n "Starting Full Backup ..."
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
export PGPORT=5432
# Connection port to the server
export PGPASSWORD=$(yq e '.postgresql.authentication.replication.password' "$PATRONI_YAML_PATH")
# Env variable for pg password. The password is extracted from the password file which is automatically created and 
# updated by Patroni
export PGDATABASE=postgres
# Env variable for initial catalog (Database)

#----------------------------------------------------------------------------
# Starting the body of the script:

(! [ -z $PATRONI_YAML_PATH ] && ! [ -z $USER ] && ! [ -z $PGPORT ] && \
! [ -z $PG_LOCAL_FULL_BACKUP_DIR ] && ! [ -z $PG_FULL_BACKUP_DIR ] && \
! [ -z $PG_FULL_BACKUP_ARCHIVE_DIR ]) || \
{ echo "At least one variable is not assigned a value to. Check your variables." >&2; exitscript 1; }
# Exit the script if any of the variables are not assigned a value to.




if [ $(ip -4 addr show $(ip -br link | awk '$1 != "lo" {print $1}' | tail -1) | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | wc -l) -ne 2 ]; then
	echo "Warning! Exiting: $BACKUP_TYPE backup process was skipped because this is not the primary replica."
	exitscript 0
fi
# Full backup will be only taken from the primary replica in a replication cluster according to the policies. A secondary replica however can
# also be manually specified.



#-------------------------- Backup process start: ------------------------------------
#CMDOUT=$(time /usr/bin/pg_basebackup -w -c fast -D $BACKUP_DIR -Ft -z -Z 1 -Xs 2>&1)


# Initialize duration with default value
duration="00:00:00:00.000"

# Create temporary file
temp_out=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

# Run command with timing
start_time=$(date +%s.%N) || start_time=$(date +%s) # Fallback to seconds precision
set +e




################################ Backup command ####################################
if psql -t -c "SELECT COUNT(*) > 0 FROM pg_stat_progress_basebackup" | grep -q f; then
	# Adjust the timeout value. Assuming the backup is being taken on a local storage, it can be set to infinity
    timeout $BACKUP_TIMEOUT_DURATION /usr/bin/pg_basebackup -w -c fast -D $BACKUP_DIR -Ft -z -Z $BACKUP_COMPRESSION_LEVEL -Xs > "$temp_out" 2>&1
	exit_code=$?
else
    echo "Skipping backup and the rest of the operation as a backup is already in progress"
    log -n "Skipping backup and the rest of the operation as a backup is already in progress"
	exitscript -1
fi
####################################################################################




set -e

if [ -e "$BACKUP_DIR" ] || [ -L "$BACKUP_DIR" ]; then
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    [ -z "$BACKUP_SIZE" ] && BACKUP_SIZE=$(ls -lh "$BACKUP_DIR" 2>/dev/null | awk '{print $5}')
else
    BACKUP_SIZE=""
fi

# Read command output safely
CMDOUT=$(cat "$temp_out" 2>/dev/null || echo "Failed to read command output")
rm -f "$temp_out"

calculate_elapsed_formatted
# Format the output based on success/failure
if [ $exit_code -eq 0 ]; then
    echo "$BACKUP_TYPE backup completed successfully."
    echo " Duration: $duration (DD:HH:MM:SS)"
    echo "Backup size: $BACKUP_SIZE"
    log -n "$BACKUP_TYPE backup completed successfully."
    log -n "Duration: $duration (DD:HH:MM:SS)"
    log -n "Backup size: $BACKUP_SIZE"
else
	echo -n "Critical error! "
	echo "$BACKUP_TYPE backup was interrupted and failed for the following reason:"
	log -n "Critical error! "
	log -n "$BACKUP_TYPE backup was interrupted and failed for the following reason:"
	if [ $exit_code -eq 124 ]; then
		CMDOUT="The user defined timeout exceeded (Exit code 124)";
	fi
	echo "$CMDOUT"
	echo "Duration: $duration (DD:HH:MM:SS)"
	echo "Leftovers size on disk: $BACKUP_SIZE"
	log -n "$CMDOUT"
	log -n "Duration: $duration (DD:HH:MM:SS)"
	log -n "Leftovers size on disk: $BACKUP_SIZE"
	exitscript -1
fi


#-------------------------- Backup process end------------------------------------


#-------------------------- Copy to remote location ------------------------------	
#CMDOUT=$(timeout 24h cp -rf "${BACKUP_DIR}" $PG_FULL_BACKUP_DIR 2>&1)
SRC="${BACKUP_DIR%/}"
CMDOUT=$(timeout 24h rsync -r --no-perms --no-owner --no-group --no-times "${SRC}" $PG_FULL_BACKUP_DIR 2>&1)

# Copy from the local to the remote backup

if [ $? -eq 0 ]; then
	log -n "Copy $BACKUP_TYPE backup to remote storage finished successfully."
	echo "Copy $BACKUP_TYPE backup to remote storage finished successfully."
else
	log -n "Copy $BACKUP_TYPE backup to remote storage failed. MSG: $CMDOUT"
	echo "Copy $BACKUP_TYPE backup to remote storage failed. MSG: $CMDOUT"
	exitscript 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	
#---------------------------------------------------------------------------------

#-------------------------- Copy to tape remote location -------------------------
#set -x
CMDOUT=$(timeout 24h cp -rf "${PG_FULL_BACKUP_DIR}""$(basename ${BACKUP_DIR})" \
$PG_FULL_BACKUP_ARCHIVE_DIR) 2>&1	
# set +x

if [ $? -eq 0 ]; then
	log -n "Copy $BACKUP_TYPE backup to remote --tape-- storage finished successfully."
	#echo "Copy $BACKUP_TYPE backup to remote --tape-- storage finished successfully."
else
	log -n "Copy $BACKUP_TYPE backup to remote --tape-- storage failed. MSG: $CMDOUT"
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
echo "Purging: "
log -n "Purging: "
run_command timeout 30m find "$PG_LOCAL_FULL_BACKUP_DIR" -maxdepth 1 -type d -mtime +2 -exec rm -rf {} +
#echo "Purge local $BACKUP_TYPE backups ... ${CMDOUT}"
log -n "Purge local $BACKUP_TYPE backups ... ${CMDOUT}"

CMDOUT=""
# For CIFS shares (slower network filesystems)
run_command timeout 1h find "$PG_FULL_BACKUP_DIR" -maxdepth 1 -type d -mtime +15 -print0 | xargs -0 -r rm -rf
# echo "Purge remote $BACKUP_TYPE backups ... ${CMDOUT}"
log -n "Purge remote $BACKUP_TYPE backups ... ${CMDOUT}"

CMDOUT=""
run_command timeout 1h find "$PG_FULL_BACKUP_ARCHIVE_DIR" -maxdepth 1 -type d -mtime +15 -print0 | xargs -0 -r rm -rf
#echo "Purge remote --tape-- $BACKUP_TYPE backups ... ${CMDOUT}"
log -n "Purge remote --tape-- $BACKUP_TYPE backups ... ${CMDOUT}"
# purging operation

if [ $OVERALL_RESULT -eq 0 ]; then
	log -n "Purging $BACKUP_TYPE backups completed successfully."
	echo "Purging $BACKUP_TYPE backups completed successfully."
	exitscript 0
	#echo "Copy full backup to remote tape storage finished successfully."
else
	log -n "Some purge $BACKUP_TYPE backup steps failed. MSG: $CMDOUT"
	echo "Some purge $BACKUP_TYPE backup steps failed. MSG: $CMDOUT"
	exitscript 1
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.
fi	
#---------------------------------------------------------------------------------


#---------------------------- Exit control ---------------------------------------
exitscript 0
#---------------------------------------------------------------------------------

