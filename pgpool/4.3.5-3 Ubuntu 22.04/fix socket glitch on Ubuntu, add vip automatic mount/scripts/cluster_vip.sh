#!/bin/bash
VIP=172.23.124.74
DEVICE=$(ip -br link | awk '$1 != "lo" {print $1}' | tail -1)

cmd1_output=$(pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1)
cmd2_output=$(pcp_node_info -h localhost -U pgpool -w | awk '{print $7}' | grep -n primary | cut -d":" -f1)
PRIMARY_NODE_LOCATION=$(echo "$cmd1_output" | sort | comm -12 - <(echo "$cmd2_output" | sort))
PRIMARY_NODE=$(pcp_node_info -h localhost -U pgpool -w | cut -d" " -f1 | sed -n "${PRIMARY_NODE_LOCATION}p")


# Command to be executed
cmd="ssh -T -i ~/.ssh/id_rsa_pgpool ${PRIMARY_NODE} /usr/bin/sudo /usr/sbin/ip addr add ${VIP}/24 dev ${DEVICE} label ${DEVICE}:0"

# Execute the command and capture the output
output=$($cmd 2>&1)

exit_code=$?
echo $exit_code

if [ "$PRIMARY_NODE" == "$(hostname)" ]; then
	cmd="/etc/pgpool2/scripts/escalation.sh 0"
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

