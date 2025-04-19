#!/bin/bash
# PostgreSQL WAL Archiving Script
set -euo pipefail




# ----------- Custom Variables -------------
# All directory path values must end with /
PG_WAL_BACKUP_ARCHIVE_ROOT_DIR=/backup/Backups/postgresql/pg-wal-backup-archive/systemd/
# Directory where backups are to be moved

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
LOG_FILE="/var/log/postgresql/pg_wal_backup_${INSTANCE}.log"
NO_FAILED_ATTEMPTS=0
SINGLE_COMMAND_OUTPUT=""
CURRENT_LOG_SIZE=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
# -----------------------------------------


# Functions ---------------------------------------------------------------
# TIMESTAMP function
get_TIMESTAMP() {
	echo $(TZ='Asia/Tehran' date +%Y-%m-%d-%H%M%S.%3N)
}

#---------- log function -----------
log() {
    local add_newline=false
    local interpret_escapes=false
	local message_content="${*:-}"
    local message=""
    local timestamp
    timestamp=$(get_TIMESTAMP 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')

	if [ $# -eq 0 ]; then 
		message_content=""; 
	else
		# Parse valid flags only if the argument is composed solely of 'n' and/or 'c'
		while [[ -n "$1" ]]; do
			if [[ "$1" == "--" ]]; then
				shift
				break
			elif [[ "$1" =~ ^-[nc]+$ ]]; then
				[[ "$1" =~ n ]] && add_newline=true
				[[ "$1" =~ c ]] && interpret_escapes=true
				shift
			else
				# Not a flag pattern, so break and treat the rest as message content.
				break
			fi
		done;
	fi

    # Build the log message.
    if [[ -z "$message_content" ]]; then
        # No message content provided: log only the timestamp on a new line.
        message=""
        add_newline=true  # Force newline even if -n was given.
    else
        message="$timestamp - ${INSTANCE:-UNKNOWN}: $message_content"
    fi

    # Output the message using the appropriate escaping and newlines.
    if $interpret_escapes; then
        if $add_newline; then
            echo -e "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2
                return 2
            }
        else
            echo -ne "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2
                return 2
            }
        fi
    else
        if $add_newline; then
            echo "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2
                return 2
            }
        else
            printf "%s" "$message" >> "${LOG_FILE:-/dev/null}" 2>/dev/null || {
                echo "log: Failed to write to '${LOG_FILE:-/dev/null}'" >&2
                return 2
            }
        fi
    fi
}


#---------------------------------

# Exit script
exitscript() {
	#echo -c "Distinct list of errors: \n---------"
	#echo -c "$CUMULATIVE_COMMAND_OUTPUT\n---------"
	echo "Duration: $duration (DD:HH:MM:SS)"
	log "Duration: $duration (DD:HH:MM:SS)"


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
    SINGLE_COMMAND_OUTPUT="$("$@" 2>&1)"  # Capture both stdout and stderr
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



log "------------------------------------- Started ------------------------------------------"
log "Starting WAL archiving ..."
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

for WAL_FILE in $(find "$PG_WAL_ARCHIVE_DIR" -type f -name "000000*" 2>/dev/null); do
  WAL_FILES_FOUND=$((WAL_FILES_FOUND + 1))
  WAL_NAME=$(basename "$WAL_FILE")
  log -n "Archiving $WAL_NAME ..."
  #echo -n "Archiving $WAL_NAME ..."
  run_command timeout 2m mv "$WAL_FILE" "$PG_WAL_BACKUP_ARCHIVE_DIR"
  MOVE_EXIT_CODE=$?
  
  if [ $MOVE_EXIT_CODE -eq 124 ]; then
  
     log " : Failed! Reason: The user defined timeout exceeded (Exit code 124)";
     #echo " : Failed! Reason: $SINGLE_COMMAND_OUTPUT"; 
  else
     log " : Failed! Reason: $SINGLE_COMMAND_OUTPUT";
  fi
  
  
  TARGET_WAL_PATH="$PG_WAL_BACKUP_ARCHIVE_DIR""$WAL_NAME"
  if [ $MOVE_EXIT_CODE -eq 0 ]; then
    CUMULATIVE_WAL_MOVED_SIZE_BYTES=$((CUMULATIVE_WAL_MOVED_SIZE_BYTES + $(du -bs "$TARGET_WAL_PATH" 2>/dev/null | awk '{print $1}')))
	WAL_FILES_MOVED=$((WAL_FILES_MOVED + 1))
  fi  
done

if [ "$WAL_FILES_FOUND" -eq 0 ]; then
  log "Warning! No WAL files were found to backup. Skipping purge."
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
	log "Moving all WAL files completed successfully. # of WAL files: $WAL_FILES_FOUND, Cumulative Size: $HUMAN_READABLE_SIZE"
	echo "Moving all WAL files completed successfully. # of WAL files: $WAL_FILES_FOUND, Cumulative Size: $HUMAN_READABLE_SIZE"
	#echo "move WAL files to remote storage finished successfully."
else
	log -n "Critical error! "	
	echo -n "Critical error! "	
	log "Moving #$NO_FAILED_ATTEMPTS/$WAL_FILES_FOUND WAL files failed. Purging skipped."
	echo "Moving #$NO_FAILED_ATTEMPTS/$WAL_FILES_FOUND WAL files failed. Purging skipped."
	# On the condition of the backup failure, the purging operation will be skipped and the
	# service will also be marked as failed for this run.

	#echo -c "Distinct list of errors: \n---------"
	#echo -c "$CUMULATIVE_COMMAND_OUTPUT\n---------"
	log -c "Distinct list of errors: \n---------"
	log -c "$(echo $CUMULATIVE_COMMAND_OUTPUT | sort -u )\n---------"	

	exitscript -1
fi


#-------------------------- Backup process end------------------------------------




timeout 1h find $PG_WAL_BACKUP_ARCHIVE_DIR -maxdepth 1 -type f -mtime +10 -print0 | xargs -0 -r rm -rf


log "WAL archiving completed successfully."
exitscript 0

