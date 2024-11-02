#!/bin/bash

# Get the current day and time
current_day=$(date +"%u")
current_time=$(date +"%H%M")

# Define the start and end time in HHMM format
start_time="0250"
end_time="0310"

# Check if it's Friday (day 5) and within the specified time range
if [[ "$current_day" -eq 5 && "$current_time" > "$start_time" && "$current_time" < "$end_time" ]]; then
    # Execute the command if the conditions are met
    etcdctl defrag
else
    echo "The script is not running within the specified time range on Friday."
fi
