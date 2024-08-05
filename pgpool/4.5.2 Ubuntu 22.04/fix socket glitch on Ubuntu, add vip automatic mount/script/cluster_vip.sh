#!/bin/bash
DEVICE=$(ip -br link | awk '$1 != "lo" {print $1}' | tail -1)
PRIMARY_NODE=$(echo $(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | head -$(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1) | tail -1 | cut -d" " -f1))

# Command to be executed
cmd="ssh -T -i ~/.ssh/id_rsa_pgpool ${PRIMARY_NODE} /usr/bin/sudo /sbin/ip addr add 172.23.124.74/24 dev ${DEVICE} label ${DEVICE}:0"

# Execute the command and capture the output
output=$($cmd 2>&1)

exit_code=$?
echo $exit_code

if [ "$PRIMARY_NODE" == "$(hostname)" ]; then
	cmd="ssh -T -i ~/.ssh/id_rsa_pgpool $(echo $(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | head -$(sudo -iu postgres pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1) | tail -1 | cut -d" " -f1)) /etc/pgpool2/scripts/escalation.sh"
	eval $cmd
fi

# Check if the output matches the desired string
if [ "$output" == "RTNETLINK answers: File exists" ]; then
# If yes, return exit code 0
	exit 0
else
# If not, return the original exit code
	exit $exit_code
fi

