#!/bin/bash
# This script is run by wd_escalation_command to bring down the virtual IP on other pgpool nodes
# before bringing up the virtual IP on the new active pgpool node.

set -o xtrace

POSTGRESQL_STARTUP_USER=postgres
SSH_KEY_FILE=id_rsa_pgpool
SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -i ~/.ssh/${SSH_KEY_FILE}"
SSH_TIMEOUT=2
# PGPOOLS=(server1 server2 server3)
PGPOOLS=(funleashpgdb01 funleashpgdb02 funleashpgdb03)

VIP=172.23.124.74
DEVICE=ens160

for pgpool in "${PGPOOLS[@]}"; do
    [ "$HOSTNAME" = "${pgpool}" ] && continue

    timeout ${SSH_TIMEOUT} ssh -T ${SSH_OPTIONS} ${POSTGRESQL_STARTUP_USER}@${pgpool} "
        /usr/bin/sudo /sbin/ip addr del ${VIP}/24 dev ${DEVICE}
    "
    if [ $? -ne 0 ]; then
		#---------------------------
		ERROR_LEVEL="error 2"
		COMMAND_PLACE_HOLDER="
		echo $(date '+%Y-%m-%d %H:%M:%S.%3N: ') script_log: $(hostname) ${ERROR_LEVEL}::: ERROR: escalation.sh: failed to release VIP on ${pgpool}."
		if [ $LOG_OUTPUT = "pgpool_log" ]; then
			COMMAND_PLACE_HOLDER=$COMMAND_PLACE_HOLDER">> $(find ${LOG_ROOT} -type f -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d ' ' -f2-)"
		fi 
		set +o xtrace; eval $COMMAND_PLACE_HOLDER; set -o xtrace;
		echo ERROR: escalation.sh: failed to release VIP on ${pgpool}.

		#---------------------------

    fi
done
exit 0
