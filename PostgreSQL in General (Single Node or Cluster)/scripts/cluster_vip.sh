#!/bin/bash
IF_NAME=$(ip -br link | awk '$1 != "lo" {print $1}' | tail -1)
# Command to be executed
cmd="ssh -T -i ~/.ssh/id_rsa_pgpool $(echo $(pcp_node_info -h localhost -U pgpool -w | head -$(pcp_node_info -h localhost -U pgpool -w | awk '{print $8}' | grep -n primary | cut -d":" -f1) | tail -1 | cut -d" " -f1)) /usr/bin/sudo /sbin/ip addr add 172.23.124.74/24 dev ${IF_NAME} label ${IF_NAME}:0"

# Execute the command and capture the output
output=$($cmd 2>&1)

exit_code=$?
echo $exit_code

# Check if the output matches the desired string
if [ "$output" == "RTNETLINK answers: File exists" ]; then
# If yes, return exit code 0
exit 0
else
# If not, return the original exit code
exit $exit_code
fi

