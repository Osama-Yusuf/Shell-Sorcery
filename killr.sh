#!/bin/bash

# Function for handling port argument
function handle_port() {
    # Check if a port number is provided as the second argument
    if [ $# -lt 1 ]; then
        echo "Usage: $0 port <port-number>"
        exit 1
    fi

    local port=$1

    # Find the process using the given port with netstat
    local pid_info=$(netstat -tulnp 2>/dev/null | grep ":$port" | awk '{print $7}')
    local pid=$(echo $pid_info | cut -d'/' -f1)

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
            echo -e "\nUnable to retrieve process details. You might need root privileges."
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
}

# Function for handling res argument
function handle_res() {
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
}

# Function for handling dock argument
function handle_dock() {
    local args=("$@")
    local option=$1

    # Help message for Docker-related operations
    if [ -z "$option" ] || [ "$option" == "-h" ] || [ "$option" == "--help" ]; then
        echo "Usage: $0 dock [OPTION]"
        echo "Options:"
        echo "  -n, --none    Remove all none images and containers"
        echo "  -l, --last      Remove last image created"
        echo "  -e, --exited    Remove all exited containers"
        echo "  -ct, --created  Remove all created containers (not running)"
        echo "  -i, --image     Remove specific image by id"
        echo "  -c, --container Remove specific container/s by id"
        echo "  -h, --help      Display this help and exit"
        return
    fi

    # Docker-related operations
    case $option in
        # [Logic for deleting all exited containers]
        -n|--none)
            echo -e "Deleting all none images & containers\n"
            images=$(docker images | grep '^<none>' | awk '{print $3}')
            conts=$(docker ps -a | grep '^<none>' | awk '{print $1}')

            if [ -n "$images" ]; then
                docker rmi -f $images
            else 
                echo "No none images"
            fi

            if [ -n "$conts" ]; then
                docker rm -f $conts
            else
                echo "No none containers"
            fi
            ;;
        # [Logic for deleting all exited containers]
        -e|--exited)
            echo -e "Deleting all exited containers"
            conts=$(docker ps -a | grep 'Exited' | awk '{print $1}')
            if [ -n "$conts" ]; then
                docker rm -f $conts
            else
                echo -e "\nNo exited containers"
            fi
            ;;
        # [Logic for deleting the last image created]
        -l|--last)
            # Cecking if there's any images exists
            if [[ "$(docker images -q)" == "" ]]; then
                echo -e "\nNo images to delete"
            else 
                echo -e "\nDeleting last image created"
                last=$(docker images | head -n 2 | tail -n 1 | awk '{print $3}')
                docker rmi -f $last
                # Checking if the last image is deleted or not
                if [ $? -eq 0 ]; then
                    echo -e "\nLast image deleted"
                else
                    echo -e "\nLast image not deleted\n"
                    read -p "Do you want to stop and delete the container? [y/n] " ans
                    if [ $ans == 'y' ]; then
                        docker ps && echo
                        read -p "Enter container ID: " cont_id
                        docker stop $cont_id
                        docker rm $cont_id
                        docker rmi -f $last
                        echo -e "\nLast image deleted"
                    else
                        echo -e "\nLast image not deleted"
                    fi
                fi
            fi
            ;;
        # [Logic for deleting all created containers]
        -ct|--created)
            echo -e "\nDeleting all created containers"
            conts=$(docker ps -a | grep 'Created' | awk '{print $1}')
            if [ -n "$conts" ]; then
                docker rm -f $conts
            else
                echo -e "\nNo created containers"
            fi
            ;;
        # [Logic for deleting specific image by id]
        -i|--image)
            # variable that stores all arguments except the first one
            local images=${args[@]:1}
            if [ -n "$images" ]; then
                local all_tags_provided=true
                for image in $images; do
                    if [[ $image != *":"* ]]; then
                        all_tags_provided=false
                        break
                    fi
                done
                if $all_tags_provided; then
                    echo -e "Trying to delete image ${args[@]:1}\n"
                    docker rmi -f $images
                else
                    echo -e "Please mention the tag alongside the image name."
                fi
            else
                echo -e "\nNo images were given."
            fi
            ;;
        # [Logic for deleting specific container/s by id]
        -c|--container)
            # variable that stores all arguments except the first one
            conts=${args[@]:1}
            echo -e "\nDeleting container $conts"
            if [ -n "$conts" ]; then
                docker rm -f $conts
            else
                echo -e "\nNo container supplied"
            fi
            ;;
        *)
            echo "Invalid option"
            echo "Try '$0 dock --help' for more information"
            ;;
    esac
}

# Function to display help message
function display_help() {
    echo "Usage: $0 [option] [args...]"
    echo "Options:"
    echo "  port <port-number>   Kills the process using the specified port."
    echo "  res <cpu|mem>        Kills the most resource-consuming process based on CPU or memory usage."
    echo "  dock [docker-options]"
    echo "                       Options for 'dock' include:"
    echo "                         -n, --none      Remove all none images and containers"
    echo "                         -l, --last      Remove last image created"
    echo "                         -e, --exited    Remove all exited containers"
    echo "                         -ct, --created  Remove all created containers (not running)"
    echo "                         -i, --image     Remove specific image/s by id"
    echo "                         -c, --container Remove specific container/s by id"
    echo "Examples:"
    echo "  $0 port 8080"
    echo "  $0 res cpu"
    echo "  $0 dock --last"
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    display_help
    exit 1
fi

# Main logic to handle arguments
case $1 in
    port)
        handle_port "${@:2}"
        ;;
    res)
        handle_res "${@:2}"
        ;;
    dock)
        handle_dock "${@:2}"
        ;;
    *)
        echo "Error: Invalid argument."
        display_help
        exit 1
        ;;
esac