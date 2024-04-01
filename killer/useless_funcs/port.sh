#!/bin/bash

# Check if an argument (port number) is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

port=$1

# Find the process using the given port with netstat
pid_info=$(netstat -tulnp 2>/dev/null | grep ":$port" | awk '{print $7}')
pid=$(echo $pid_info | cut -d'/' -f1)

# Check if netstat output is a dash or empty, then try with lsof
if [ "$pid" = "-" ] || [ -z "$pid" ]; then
    pid=$(lsof -i TCP:$port -t 2>/dev/null)
fi

# Check if any valid process ID is found
if [ -z "$pid" ]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "Some processes may be hidden; run as root for full visibility"
    else
        echo "No process is using port $port"
    fi
    exit 0
else
    # Display process details
    echo "Process using port $port:"
    ps -p $pid -o comm,pcpu,pid
    if [ $? -ne 0 ]; then
        echo "Unable to retrieve process details. You might need root privileges."
        exit 1
    fi

    while true; do
        # Display message and wait for user input
        read -p "Press Enter to kill the process or Ctrl+C to exit." -r key

        # Check if Enter key is pressed
        if [ -z "$key" ]; then
            # Kill the process
            kill $pid
            echo "Process killed."
            break
        else
            echo "Invalid input. Try again."
        fi
    done
fi