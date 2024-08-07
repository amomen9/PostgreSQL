#!/bin/bash
# This script is run by failover_command.

set -o xtrace

# Special values:
# 1)  %d = failed node id
# 2)  %h = failed node hostname
# 3)  %p = failed node port number
# 4)  %D = failed node database cluster path
# 5)  %m = new main node id
# 6)  %H = new main node hostname
# 7)  %M = old main node id
# 8)  %P = old primary node id
# 9)  %r = new main port number
# 10) %R = new main database cluster path
# 11) %N = old primary node hostname
# 12) %S = old primary node port number
# 13) %% = '%' character

FAILED_NODE_ID="$1"
FAILED_NODE_HOST="$2"
FAILED_NODE_PORT="$3"
FAILED_NODE_PGDATA="$4"
NEW_MAIN_NODE_ID="$5"
NEW_MAIN_NODE_HOST="$6"
OLD_MAIN_NODE_ID="$7"
OLD_PRIMARY_NODE_ID="$8"
NEW_MAIN_NODE_PORT="$9"
NEW_MAIN_NODE_PGDATA="${10}"
OLD_PRIMARY_NODE_HOST="${11}"
OLD_PRIMARY_NODE_PORT="${12}"


# PGHOME=/usr/pgsql-15
PGHOME=$(which psql | rev | cut -d"/" -f3- | rev)
PGMAJVER=$((`psql -tc "show server_version_num"` / 10000))
PGCLU=main
# REPL_SLOT_NAME=$(echo ${FAILED_NODE_HOST,,} | tr -- -. _)
REPL_SLOT_RAW_NAME=$(echo ${FAILED_NODE_HOST} | cut -c 2-)
REPL_SLOT_NAME=$(echo ${REPL_SLOT_RAW_NAME,,} | tr -- -. _)

POSTGRESQL_STARTUP_USER=postgres
SSH_KEY_FILE=id_rsa_pgpool
SSH_OPTIONS="-o StrictHostKeyChecking=no -o ConnectTimeout=2 -i ~/.ssh/${SSH_KEY_FILE}"


COMMAND_PLACE_HOLDER=""
LOG_LEVEL=$(cat script.conf | grep log_level | cut -d'=' -f2 | tr -d "'")
LOG_OUTPUT=$(cat script.conf | grep log_destination | cut -d'=' -f2 | tr -d "'")
PGCONF_PATH=$(echo /etc/postgresql/${PGMAJVER}/${PGCLU}/postgresql.conf)
PGPOOLCONF_PATH=$(echo /etc/pgpool2/pgpool.conf)
LOG_ROOT="/"$(cat ${PGPOOLCONF_PATH} | grep ^log_directory | cut -d "/" -f2- | tr -d "'")
ERROR_LEVEL=""

##### end variables ####################################################

#---------------------------
ERROR_LEVEL="info"
COMMAND_PLACE_HOLDER="
echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: start: failed_node_id=\$FAILED_NODE_ID failed_host=\$FAILED_NODE_HOST \
old_primary_node_id=\$OLD_PRIMARY_NODE_ID new_main_node_id=\$NEW_MAIN_NODE_ID new_main_host=\$NEW_MAIN_NODE_HOST"
if [ $LOG_OUTPUT = "pgpool_log" ]; then
	COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
fi 
set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
echo failover.sh: start: failed_node_id=$FAILED_NODE_ID failed_host=$FAILED_NODE_HOST \
    old_primary_node_id=$OLD_PRIMARY_NODE_ID new_main_node_id=$NEW_MAIN_NODE_ID new_main_host=$NEW_MAIN_NODE_HOST

#---------------------------

# determine recovery conf file name
if [ $PGVERSION -ge 12 ]; then
    RECOVERYCONF=${NODE_PGDATA}/myrecovery.conf
else
    RECOVERYCONF=${NODE_PGDATA}/recovery.conf
fi


## If there's no main node anymore, skip failover.
if [ $NEW_MAIN_NODE_ID -lt 0 ]; then
  
	#---------------------------
	ERROR_LEVEL="error 2"
	COMMAND_PLACE_HOLDER="
	echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: All nodes are down. Skipping failover."
	if [ $LOG_OUTPUT = "pgpool_log" ]; then
		COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
	fi 
	set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
    echo failover.sh: All nodes are down. Skipping failover.

	#---------------------------

    exit 2
fi

## Test passwordless SSH
ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} ls /tmp > /dev/null

if [ $? -ne 0 ]; then
	#---------------------------
	ERROR_LEVEL="error 1"
	COMMAND_PLACE_HOLDER="
	echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: passwordless SSH to ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} failed. Please setup passwordless SSH."
	if [ $LOG_OUTPUT = "pgpool_log" ]; then
		COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
	fi 
	set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
    echo failover.sh: passwordless SSH to ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} failed. Please setup passwordless SSH.

	#---------------------------

  
    exit 1
fi

## If Standby node is down, skip failover.
COMMAND_PLACE_HOLDER="echo $(date '+%Y-%m-%d %H:%M:%S.%3N: '): $(hostname): script_log: OLD_PRIMARY_NODE_ID=${OLD_PRIMARY_NODE_ID}, FAILED_NODE_ID=${FAILED_NODE_ID} >> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
eval $COMMAND_PLACE_HOLDER
if [ $OLD_PRIMARY_NODE_ID != "-1" -a $FAILED_NODE_ID != $OLD_PRIMARY_NODE_ID ]; then

    # If Standby node is down, drop replication slot.
    ${PGHOME}/bin/psql -h ${OLD_PRIMARY_NODE_HOST} -p ${OLD_PRIMARY_NODE_PORT} postgres \
        -c "SELECT pg_drop_replication_slot('${REPL_SLOT_NAME}');"  >/dev/null 2>&1

    if [ $? -ne 0 ]; then
		#---------------------------
		ERROR_LEVEL="info"
		COMMAND_PLACE_HOLDER="
		echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: drop replication slot '\"${REPL_SLOT_NAME}\"' failed. You may need to drop replication slot manually."
		if [ $LOG_OUTPUT = "pgpool_log" ]; then
			COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
		fi 
		set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
        echo ERROR: failover.sh: drop replication slot \"${REPL_SLOT_NAME}\" failed. You may need to drop replication slot manually.

		#---------------------------
  
    fi
	#---------------------------
	ERROR_LEVEL="error 2"
	COMMAND_PLACE_HOLDER="
	echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: end: standby node '\"${NEW_MAIN_NODE_HOST}\"' is down. Skipping failover."
	if [ $LOG_OUTPUT = "pgpool_log" ]; then
		COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
	fi 
	set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
    echo failover.sh: end: standby node is down. Skipping failover.

	#---------------------------
  
    exit 2
fi

## Promote Standby node.
#---------------------------
ERROR_LEVEL="info"
COMMAND_PLACE_HOLDER="
echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: failover.sh: primary node is down or a manual failover has been requsted, promote new_main_node_id=$NEW_MAIN_NODE_ID on ${NEW_MAIN_NODE_HOST}."
if [ $LOG_OUTPUT = "pgpool_log" ]; then
	COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
fi 
set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
echo failover.sh: primary node is down, promote new_main_node_id=$NEW_MAIN_NODE_ID on ${NEW_MAIN_NODE_HOST}.

#---------------------------


#ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} ${PGHOME}/bin/pg_ctl -D ${NEW_MAIN_NODE_PGDATA} -w promote
ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} ${PGHOME}/bin/pg_ctlcluster $PGMAJVER $PGCLU promote -- -w -D ${NEW_MAIN_NODE_PGDATA}

if [ $? -ne 0 ]; then
	#---------------------------
	ERROR_LEVEL="error 1"
	COMMAND_PLACE_HOLDER="
	echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: ERROR: failover.sh: promote '\"${NEW_MAIN_NODE_HOST}\"' failed"
	if [ $LOG_OUTPUT = "pgpool_log" ]; then
		COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
	fi 
	set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
    echo ERROR: failover.sh: promote failed

	#---------------------------
  
    exit 1
else
	# Remove standby.signal on the new primary and restart the pg service (RECOVERYCONF may or may not be removed) amomen
	ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} rm -f $NEW_MAIN_NODE_PGDATA/standby.signal
	#---------------------------
	ERROR_LEVEL="error 2"
	COMMAND_PLACE_HOLDER="
	echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: ERROR: failover.sh: removing standby.signal and RECOVERYCONF files on the new primary '\"${NEW_MAIN_NODE_HOST}\"' failed. Remove them manually and restart the pg service."
	if [ $LOG_OUTPUT = "pgpool_log" ]; then
		COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
	fi 
	set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
	# needs not echo
	#---------------------------
	if [ $? -ne 0 ]; then
		# Restart pg service on the new primary to take promotion into effect
		ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${NEW_MAIN_NODE_HOST} ${PGHOME}/bin/pg_ctlcluster $PGMAJVER $PGCLU restart -m immediate
		#---------------------------
		ERROR_LEVEL="error 1"
		COMMAND_PLACE_HOLDER="
		echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: ERROR: failover.sh: restarting pg service on the new primary '\"${NEW_MAIN_NODE_HOST}\"' failed. Critical! cluster is down"
		if [ $LOG_OUTPUT = "pgpool_log" ]; then
			COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
		fi 
		set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
		# needs not echo
		#---------------------------
	fi
fi
#---------------------------
ERROR_LEVEL="info"
COMMAND_PLACE_HOLDER="
echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: ERROR: failover.sh: end: new_main_node_id=$NEW_MAIN_NODE_ID on ${NEW_MAIN_NODE_HOST} was successfully promoted to primary"
if [ $LOG_OUTPUT = "pgpool_log" ]; then
	COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
fi 
set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
echo failover.sh: end: new_main_node_id=$NEW_MAIN_NODE_ID on ${NEW_MAIN_NODE_HOST} was successfully promoted to primary

#---------------------------

exit 0
