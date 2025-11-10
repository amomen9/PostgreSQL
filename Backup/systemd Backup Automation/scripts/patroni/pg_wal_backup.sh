#!/bin/bash
# PostgreSQL WAL Archiving Script
set -euo pipefail




# ----------- Custom Variables -------------
# All directory path values must end with /
PG_WAL_BACKUP_ARCHIVE_ROOT_DIR=/backup/Backups/postgresql/pg-wal-backup/systemd/
# Directory where backups are to be copied to
PG_WAL_TapeBACKUP_ARCHIVE_ROOT_DIR=/backup/TapeBackups/postgresql/pg-wal-backup/systemd/
# Tape Directory where backups are to be copied to

PG_WAL_ARCHIVE_DIR=/archive/postgresql/pg-wal-archive/
# The directory where PostgreSQL DB Cluster copies the generated WAL files for archiving.
# Note: Every node in a clustered replication generates its own WAL files, and thus we will
# have # of nodes backup archives.
MAX_LOG_SIZE=$((100*1024*1024))  # 100MB in bytes, Custom maximum allowed size for the log file
BACKUP_TYPE="WAL"
CUMULATIVE_COMMAND_OUTPUT=""
OUTPUT_MODE=""		# STDOUT STDERR LOG ALL
# ------------------------------------------


# ---------- Calculated Variables ---------
INSTANCE=$(yq eval '.scope' /etc/patroni/config.yml)
PG_WAL_BACKUP_ARCHIVE_DIR="$PG_WAL_BACKUP_ARCHIVE_ROOT_DIR""$(hostname)/"
PG_WAL_TapeBACKUP_ARCHIVE_DIR="$PG_WAL_TapeBACKUP_ARCHIVE_ROOT_DIR""$(hostname)/"
LOG_FILE="/var/log/postgresql/pg_wal_backup_${INSTANCE}.log"
NO_FAILED_ATTEMPTS=0
SINGLE_COMMAND_OUTPUT=""
CURRENT_LOG_SIZE=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
# -----------------------------------------
# ---------- Create directories -----------
mkdir -p $PG_WAL_BACKUP_ARCHIVE_ROOT_DIR $PG_WAL_ARCHIVE_DIR $PG_WAL_BACKUP_ARCHIVE_DIR
#------------------------------------------


# Functions ---------------------------------------------------------------
# TIMESTAMP function
get_TIMESTAMP() {
	echo $(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N)
}

#---------- log function -----------

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


#---------------------------------

# Exit script
exitscript() {
	#echo "Distinct list of errors: \n---------"
	#echo "$CUMULATIVE_COMMAND_OUTPUT\n---------"
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

# Multiple commands exit code check
run_command() {
    SINGLE_COMMAND_OUTPUT="$("$@" 2>&1 | tr -d '\0')"  # Capture both stdout and stderr
    CUMULATIVE_COMMAND_OUTPUT="$CUMULATIVE_COMMAND_OUTPUT"$'\n'"$SINGLE_COMMAND_OUTPUT" # Run command, append stdout/stderr to SINGLE_COMMAND_OUTPUT
    local exit_code=$?             # Capture exit code (use `local` to avoid global var)
    
    if [ $exit_code -ne 0 ]; then
        NO_FAILED_ATTEMPTS=$((NO_FAILED_ATTEMPTS + 1))  # Increment failure counter
    fi
    
    return $exit_code  # Return the exit code to the caller
}


bytes_to_human() {
    echo "$1" | awk '{
        if ($1 < 1024) printf "%d B\n", $1;
        else if ($1 < 1048576) printf "%d KB\n", $1/1024;
        else if ($1 < 1073741824) printf "%.1f MB\n", $1/1048576;
        else printf "%.1f GB\n", $1/1073741824;
    }'
}

# -------------------------------------------------------------------------




# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p $PG_WAL_BACKUP_ARCHIVE_DIR




if [ "$CURRENT_LOG_SIZE" -gt "$MAX_LOG_SIZE" ]; then
    > "$LOG_FILE"
    echo "Truncated $LOG_FILE (was ${CURRENT_LOG_SIZE} bytes)"
fi



log -n "------------------------------------- Started ------------------------------------------"
log -n "Starting WAL archiving ..."
echo
echo
echo "------------------------------------- Started ------------------------------------------"
echo "Starting WAL archiving ..."
echo "log file path: $LOG_FILE"


#-------------------------- Backup process start: ------------------------------------



# Initialize duration with default value
duration="00:00:00:00.000"

# Run command with timing
start_time=$(date +%s.%N) || start_time=$(date +%s) # Fallback to seconds precision
set +e

###### ------------------ Backup command --------------------
SINGLE_COMMAND_OUTPUT=""
NO_FAILED_ATTEMPTS=0
# Archive all pending WAL files
WAL_FILES_FOUND=0
WAL_FILES_MOVED=0
CUMULATIVE_WAL_MOVED_SIZE_BYTES=0
TARGET_WAL_PATH=""
MOVE_EXIT_CODE=1

for WAL_FILE in $(find "$PG_WAL_ARCHIVE_DIR" -type f -name "000000*" 2>/dev/null | sort ); do
  WAL_FILES_FOUND=$((WAL_FILES_FOUND + 1))
  WAL_NAME=$(basename "$WAL_FILE")
  log "Archiving $WAL_NAME ..."
  # echo "Archiving $WAL_NAME ..."
  # On Linux filesystems, use "mv" to preserve file stats
  # run_command timeout 2m mv "$WAL_FILE" "$PG_WAL_BACKUP_ARCHIVE_DIR"
  
  # On samba shares use "cp --no-preserve=mode,ownership,timestamps" to dismiss preservation of file stats and avoid errors,
  # but file stats will be lost!!!
  run_command timeout 2m rsync --no-perms --no-owner --no-group --no-times "$WAL_FILE" "$PG_WAL_BACKUP_ARCHIVE_DIR" && rm -f "$WAL_FILE"
  # Success of the former command is enough
  MOVE_EXIT_CODE=$?
  
  # Tape backup
  run_command timeout 2m rsync --no-perms --no-owner --no-group --no-times "$PG_WAL_BACKUP_ARCHIVE_DIR""/$WAL_NAME" "$PG_WAL_TapeBACKUP_ARCHIVE_DIR"
  
  if [ $MOVE_EXIT_CODE -eq 124 ]; then
  
     log -n --no-ts " : Failed! Reason: The user defined timeout exceeded (Exit code 124)";
     #echo " : Failed! Reason: $SINGLE_COMMAND_OUTPUT"; 
  elif [ $MOVE_EXIT_CODE -ne 0 ]; then
     log -n --no-ts " : Failed! Reason: $SINGLE_COMMAND_OUTPUT";
  fi
  
  
  TARGET_WAL_PATH="$PG_WAL_BACKUP_ARCHIVE_DIR""$WAL_NAME"
  if [ $MOVE_EXIT_CODE -eq 0 ]; then
     log -n --no-ts " Passed.";
     CUMULATIVE_WAL_MOVED_SIZE_BYTES=$((CUMULATIVE_WAL_MOVED_SIZE_BYTES + $(du -bs "$TARGET_WAL_PATH" 2>/dev/null | awk '{print $1}')))
	 WAL_FILES_MOVED=$((WAL_FILES_MOVED + 1))
  fi  
done

if [ "$WAL_FILES_FOUND" -eq 0 ]; then
  log -n "Warning! No WAL files were found to backup. Skipping purge."
  echo "Warning! No WAL files were found to backup. Skipping purge."
  exitscript 0
fi



HUMAN_READABLE_SIZE=$(bytes_to_human ${CUMULATIVE_WAL_MOVED_SIZE_BYTES})


###### ------------------------------------------------------

exit_code=$NO_FAILED_ATTEMPTS
set -e
end_time=$(date +%s.%N) || end_time=$(date +%s) # Fallback to seconds precision


## Read command output safely
#if [ -e "$temp_out" ]; then
#  eval $(cat "$temp_out" 2>/dev/null || echo "Failed to read command output")
#rm -f "$temp_out"

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
	log -n "Moving all WAL files completed successfully. # of WAL files: $WAL_FILES_FOUND, Cumulative Size: $HUMAN_READABLE_SIZE"
	echo "Moving all WAL files completed successfully. # of WAL files: $WAL_FILES_FOUND, Cumulative Size: $HUMAN_READABLE_SIZE"
	#echo "move WAL files to remote storage finished successfully."
else
	log -n "Critical error! "	
	echo -n "Critical error! "	
	log -n "Moving #$NO_FAILED_ATTEMPTS/$WAL_FILES_FOUND WAL files failed. Purging skipped."
	echo "Moving #$NO_FAILED_ATTEMPTS/$WAL_FILES_FOUND WAL files failed. Purging skipped."
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.

	#echo "Distinct list of errors: \n---------"
	#echo "$CUMULATIVE_COMMAND_OUTPUT\n---------"
	log -c "Distinct list of errors: \n---------"
	log -c "$(echo $CUMULATIVE_COMMAND_OUTPUT | sort -u )\n---------"	

	exitscript -1
fi


#-------------------------- Backup process end------------------------------------


#-------------------------- Purge process start: ---------------------------------


timeout 30m find $PG_WAL_BACKUP_ARCHIVE_ROOT_DIR -type f -mtime +10 -print0 | xargs -0 -r rm -rf

if [ $? -ne 0 ]; then 
	log -n "Purge failed." #"Output returned by the purge command: ${SINGLE_COMMAND_OUTPUT}"
	echo "Purge failed."
	exitscript 5	
fi

echo "WAL archiving & purging completed successfully."
log -n "WAL archiving & purging completed successfully."

#-------------------------- Purge process end ------------------------------------


exitscript 0

