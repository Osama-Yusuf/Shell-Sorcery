#!/bin/bash

# Function to display process info and prompt for confirmation
confirm_and_kill() {
    local pid=$1
    local detail=$2

    # Get process name by PID
    local proc_name=$(ps -p $pid -o comm=)

    echo "PID: $pid, Name: $proc_name, Consuming $detail"
    echo "Press Enter to kill this process or Ctrl+C to abort..."
    read enter # Wait for user to press Enter

    kill -9 $pid
    echo "Process killed."
}

# Check if the argument is cpu or mem
if [ "$1" == "cpu" ]; then
    # Find the PID and CPU% of the most CPU-consuming process
    read pid cpu <<< $(ps -eo pid,%cpu --sort=-%cpu | head -n 2 | tail -n 1 | awk '{print $1, $2}')
    confirm_and_kill $pid $cpu%

elif [ "$1" == "mem" ]; then
    # Find the PID and MEM% of the most memory-consuming process
    read pid mem <<< $(ps -eo pid,%mem --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $1, $2}')
    confirm_and_kill $pid $mem%

else
    echo "Invalid argument. Please use 'cpu' or 'mem'."
fi
