#!/bin/bash

# Function for handling port argument
handle_port() {
  if [ $# -lt 1 ]; then
    echo "Usage: $0 port <port-number> [--include-root]"
    exit 1
  fi

  local port="$1"
  shift || true
  local include_root="no"
  [ "${1:-}" = "--include-root" ] && include_root="yes"

  # Gather candidate PIDs (listeners + connections)
  collect_pids() {
    local pids=""
    if command -v lsof >/dev/null 2>&1; then
      pids="$pids $(lsof -nP -iTCP:$port -sTCP:LISTEN -t 2>/dev/null)"
      pids="$pids $(lsof -nP -iTCP:$port -t 2>/dev/null)"
    fi
    if [ -z "$pids" ] && command -v ss >/dev/null 2>&1; then
      pids="$pids $(ss -lptn "sport = :$port" 2>/dev/null | awk -F 'pid=' 'NR>1{split($2,a,/,/);if(a[1]~/^[0-9]+$/)print a[1]}')"
      pids="$pids $(ss -ptn "sport = :$port" 2>/dev/null  | awk -F 'pid=' 'NR>1{split($2,a,/,/);if(a[1]~/^[0-9]+$/)print a[1]}')"
    fi
    echo "$pids" | tr ' ' '\n' | awk '/^[0-9]+$/{print}' | awk '!seen[$0]++'
  }

  PID_LIST="$(collect_pids)"

  if [ -z "$PID_LIST" ]; then
    if [ "$(id -u)" -ne 0 ]; then
      echo "No visible process is using port $port. Some may require sudo to see."
    else
      echo "No process is using port $port."
    fi
    exit 0
  fi

  echo "Found PID(s) using port $port:"
  echo "$PID_LIST" | tr ' ' '\n'

  for pid in $PID_LIST; do
    owner="$(ps -p "$pid" -o user= 2>/dev/null | awk '{print $1}')"
    [ -z "$owner" ] && continue
    if [ "$include_root" != "yes" ] && [ "$owner" = "root" ]; then
      echo "Skipping PID $pid (root-owned). Use --include-root to target it."
      continue
    fi

    line="$(ps -p "$pid" -o pid= -o user= -o pcpu= -o pmem= -o command= | \
      awk '{printf "PID:%s USER:%s CPU:%s%% MEM:%s%% CMD:%s\n",$1,$2,$3,$4,substr($0, index($0,$5))}')"

    echo "———"
    echo "$line"
    echo "Action: [Enter]=TERM, 9=SIGKILL, s=skip, q=quit"
    read -r choice

    case "$choice" in
      9) kill -9 "$pid" && echo "Killed PID $pid (SIGKILL)." ;;
      s|S) echo "Skipped PID $pid." ; continue ;;
      q|Q) echo "Quit." ; exit 0 ;;
      *)   kill "$pid" && echo "Terminated PID $pid (SIGTERM)." ;;
    esac
  done
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

    local mode=$1
    local pid=""
    local metric=""

    if [ "$mode" == "cpu" ]; then
        if [ "$(uname -s)" = "Darwin" ]; then
            # macOS: sort by CPU with -r
            read pid metric <<< $(ps -Ao pid,pcpu -r | awk 'NR==2 {print $1, $2}')
        else
            # GNU ps
            read pid metric <<< $(ps -eo pid,%cpu --sort=-%cpu | awk 'NR==2 {print $1, $2}')
        fi
    elif [ "$mode" == "mem" ]; then
        if [ "$(uname -s)" = "Darwin" ]; then
            # macOS: sort by memory with -m
            read pid metric <<< $(ps -Ao pid,pmem -m | awk 'NR==2 {print $1, $2}')
        else
            # GNU ps
            read pid metric <<< $(ps -eo pid,%mem --sort=-%mem | awk 'NR==2 {print $1, $2}')
        fi
    else
        echo "Invalid argument. Please use 'cpu' or 'mem'."
        return 1
    fi

    # Validate PID before proceeding
    case "$pid" in
        ""|*[!0-9]*)
            echo "Unable to determine the target process."
            return 1
            ;;
    esac

    confirm_and_kill "$pid" "${metric}%"
}
# Function to check if Docker or Podman is installed and available
check_container_tool() {
    if command -v docker &> /dev/null; then
        docker ps &> /dev/null
        if [ $? -eq 0 ]; then
            echo "docker"
            return 0
        fi
    fi

    if command -v podman &> /dev/null; then
        podman ps &> /dev/null
        if [ $? -eq 0 ]; then
            echo "podman"
            return 0
        fi
    fi

    echo "none"
    return 1
}

# Function for handling dock argument
function handle_dock() {
    local args=("$@")
    local option=$1

    # Determine the container tool to use
    local container_tool=$(check_container_tool)
    if [ "$container_tool" == "none" ]; then
        echo "Neither Docker nor Podman is installed or accessible on this machine."
        return 1
    # else
    #     echo "Using $container_tool"
    fi

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
        echo "  -k, --kill kill specific container/s by id"
        echo "  -h, --help      Display this help and exit"
        return
    fi

    # Inner function to select Docker images or containers using fzf
    select_with_fzf() {
        local mode=$1 # "image" or "container"
        local selected

        if [ "$mode" == "image" ]; then
            selected=$($container_tool images | grep -v REPOSITORY | fzf --height 40% --border --ansi | awk '{print $3}')
        elif [ "$mode" == "container" ]; then
            selected=$($container_tool ps -a | grep -v "CONTAINER ID" | fzf --height 40% --border --ansi | awk '{print $1}')
        fi

        echo "$selected"
    }

    # Docker-related operations
    case $option in
        # [Logic for deleting all exited containers]
        -n|--none)
            echo -e "Deleting all none images & containers\n"
            images=$($container_tool images | grep '^<none>' | awk '{print $3}')
            conts=$($container_tool ps -a | grep '^<none>' | awk '{print $1}')

            if [ -n "$images" ]; then
                $container_tool rmi -f $images
            else 
                echo "No none images"
            fi

            if [ -n "$conts" ]; then
                $container_tool rm -f $conts
            else
                echo "No none containers to delete."
            fi
            ;;
        # [Logic for deleting all exited containers]
        -e|--exited)
            echo -e "Deleting all exited containers"
            conts=$($container_tool ps -a | grep 'Exited' | awk '{print $1}')
            if [ -n "$conts" ]; then
                $container_tool rm -f $conts
            else
                echo -e "\nNo exited containers"
            fi
            ;;
        # [Logic for deleting the last image created]
        -l|--last)
            # Cecking if there's any images exists
            if [[ "$($container_tool images -q)" == "" ]]; then
                echo -e "\nNo images to delete"
            else 
                echo -e "\nDeleting last image created"
                last=$($container_tool images | head -n 2 | tail -n 1 | awk '{print $3}')
                $container_tool rmi -f $last
                # Checking if the last image is deleted or not
                if [ $? -eq 0 ]; then
                    echo -e "\nLast image deleted"
                else
                    echo -e "\nLast image not deleted\n"
                    read -p "Do you want to stop and delete the container? [y/n] " ans
                    if [ $ans == 'y' ]; then
                        $container_tool ps && echo
                        read -p "Enter container ID: " cont_id
                        $container_tool stop $cont_id
                        $container_tool rm $cont_id
                        $container_tool rmi -f $last
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
            conts=$($container_tool ps -a | grep 'Created' | awk '{print $1}')
            if [ -n "$conts" ]; then
                $container_tool rm -f $conts
            else
                echo -e "\nNo created containers to delete."
            fi
            ;;
        # [Logic for deleting specific image by id]
        -i|--image)
            local selected_images=$(select_with_fzf image)
            if [ -n "$selected_images" ]; then
                $container_tool rmi -f $selected_images
            else
                echo "No images selected to delete."
            fi
            ;;
        # [Logic for deleting specific container/s by id]
        -c|--container)
            local selected_containers=$(select_with_fzf container)
            if [ -n "$selected_containers" ]; then
                $container_tool rm -f $selected_containers
            else
                echo "No containers selected to delete."
            fi
            ;;
        # [Logic for deleting specific container/s by id]
        -k|--kill)
            local selected_containers=$(select_with_fzf container)
            if [ -n "$selected_containers" ]; then
                $container_tool kill -f $selected_containers
            else
                echo "No containers selected to kill."
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
    echo "                         -k, --kill kill specific container/s by id"
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
