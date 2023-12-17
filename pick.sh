#!/bin/bash

# execute set-x if got --debug flag at any position as argument
if [[ "$*" == *--debug* ]]
then
	set -x
fi

# ---------------- get hosts from .ssh/config then ssh into it --------------- #
# host=$(cat .ssh/config | grep "Host " | grep -v "#" | awk '{print $2}' | fzf)
# ssh $host
# ---------------------------------------------------------------------------- #

CONFIG_FILE=~/.config/pickhost/hosts

pickhost_checker() {
	# check if pickhost is installed if not install it
	if ! command -v pickhost &> /dev/null
	then
		echo "pickhost isn't installed, installing it now..."
		python3 -m pip install pickhost # https://github.com/rayx/pickhost
	fi
}

host_selector() {
	# pickhost an opensource project for sshing into hosts & this where you write your hosts ~/.config/pickhost/hosts and is better than using fzf with .ssh/host like above
    unset PH_NAME PH_USER PH_HOST
    eval $(pickhost 2>&1 >/dev/tty)
    # Return if no entry is selected.
    [[ -n $PH_NAME ]] || return 0
    echo -e "Logging into ${PH_NAME}...\n"
    ssh ${PH_USER}@${PH_HOST}
    # echo "ssh ${PH_USER}@${PH_HOST}"
}

fzf_checker() {
	# check if fzf is installed if not install it
	if ! command -v fzf &> /dev/null
	then
		echo "fzf isn't installed, installing it now..."
		sudo apt install fzf
	fi
}

namespace_selector() {
	# select namespace then switch to it
	namespace=$(kubectl get ns | grep -v NAME | awk '{print $1}' | fzf --multi --cycle --reverse --height 50% --border --prompt "Select a namespace: " --preview "echo {}" --preview-window down:1:wrap)
	if [ "$namespace" == "" ]
	then
		echo "No namespace selected"
		exit 1
	fi
	kubectl config set-context --current --namespace=$namespace
}

eks_selector() {
	selected_cluster=$(kubectl config get-contexts | grep -v NAME | awk '{print $2}' | fzf --multi --cycle --reverse --height 10% --border --prompt "Select a cluster: " --preview "echo {}" --preview-window down:1:wrap)
	# Check if a cluster was selected
	if [ -z "$selected_cluster" ]; then
		echo "No clustery selected. Exiting."
		exit 1
	fi
	kubectl config use-context $selected_cluster
}

aws_selector() {
	credentials_file="$HOME/.aws/credentials"

	# if the creds file doesn't exist exit
	if [ ! -f "$credentials_file" ]; then
		echo "AWS credentials file not found: $credentials_file"
		exit 1
	fi

	# extract profile names to use with fzf later
	profile_names=$(grep -E '^\[.*\]' "$credentials_file" | tr -d '[]')

	# prompt the user to choose a profile wit fzf
	selected_profile=$(echo "$profile_names" | fzf --multi --cycle --reverse --height 50% --border --prompt "Select an AWS profile: " --preview "echo {}" --preview-window down:1:wrap)

	# if no profile selected exit (input validation)
	if [ -z "$selected_profile" ]; then
		echo "No profile selected. Exiting."
		exit 1
	fi

	# check if AWS_PROFILE is already set in .bashrc
	if grep -q "export AWS_PROFILE=" "$HOME/.bashrc"; then
		# update the existing AWS_PROFILE value
		sed -i -e "s/export AWS_PROFILE=.*/export AWS_PROFILE=$selected_profile/" "$HOME/.bashrc"
	else
		# append the export statement to .bashrc
		echo "export AWS_PROFILE=$selected_profile" >> "$HOME/.bashrc"
	fi

	# source the .bashrc file to apply changes in the current session
	source "$HOME/.bashrc"

	echo "AWS profile '$selected_profile' set as the default profile."

	if [ "$0" = "$BASH_SOURCE" ]; then
		# if not sourced
		$SHELL
	fi
}

# Function to list and select a group using fzf
select_group() {
    # Extract groups from the config file and select using fzf
    selected_group=$(grep '^\[' "$CONFIG_FILE" | sed 's/[][]//g' | fzf --multi --cycle --reverse --height 10% --border --prompt "Select a group: " --preview "echo {}" --preview-window down:1:wrap)
    echo "$selected_group"
}

# Function to list and select a host using fzf
select_host() {
    local selected_host=$(grep ' = ' "$CONFIG_FILE" | fzf --multi --cycle --reverse --height 10% --border --prompt "Select a host: " --preview "echo {}" --preview-window down:1:wrap)
    echo "$selected_host"
}

# Function to add a host
add_host() {
    local host_name=$1
    local host_user_IP=$2

    # Add host to the specified group
    sed -i "/^\[$group\]/a $host_name = $host_user_IP" "$CONFIG_FILE"
    echo -e "\nHost added to $group group (make sure to add your public key to the host authorized_keys file)"
}

add_group() {
	local group=$1
	# Check if the group exists, if not create it
	if ! grep -q "\[$group\]" "$CONFIG_FILE"; then
		echo -e "\n[$group]" >> "$CONFIG_FILE"
		echo "Group $group created."
	else
		echo "Group $group already exists."
		exit 1
	fi
}

del_group() {
	group=$(select_group)
	if [ -z "$group" ]; then
		echo "No group selected. Exiting."
		exit 1
	else
		echo "Deleting $group..."
		sed -i "/^\[$group\]/,/^\[.*\]/d" "$CONFIG_FILE"
		echo "Group $group deleted."
	fi
}

del_host(){
	unset PH_NAME PH_USER PH_HOST
	eval $(pickhost 2>&1 >/dev/tty)
	# Return if no entry is selected.
	# [[ -n $PH_NAME ]] || return 0
	echo -e "Deleting ${PH_NAME}...\n"
	sed -i "/$PH_NAME/d" "$CONFIG_FILE"
	echo "Host $PH_NAME deleted."
}

if [ "$1" == "eks" ]
then
	if [ "$2" == "cur" ]
	then
		kubectl config current-context
		exit 1
	elif [  "$2" == "update" ]
	then
		if [ -z "$3" ]; then
			echo "No cluster given. Exiting."
			exit 1
		fi
		aws eks update-kubeconfig --name $3
		exit 1
	fi
	fzf_checker
	eks_selector
elif [ "$1" == "aws" ]
then
	if [ "$2" == "cur" ]
	then
		echo $AWS_PROFILE
		exit 1
	fi
	fzf_checker
	aws_selector
elif [ "$1" == "ns" ]
then
	if [ "$2" == "cur" ]
	then
		kubectl config view --minify --output 'jsonpath={..namespace}'
		exit 1
	fi
	# check if fzf is installed if not install it
	fzf_checker
	namespace_selector
elif [ "$1" == "host" ] && [ "$2" == "add" ]; then
	if [ "$3" == "host" ]
	then
		if [ $# -eq 5 ]; then
			group=$(select_group)
			if [ -z "$group" ]; then
				echo "No group selected. Exiting."
				exit 1
			fi
			add_host "$4" "$5"
			exit 1
		else
			echo "Usage: pick.sh host add <host_name> <host_user>@<host_ip>"
			exit 1
		fi
		# add_host $4 $5 $6 $7
	elif [ "$3" == "group" ]
	then
		if [ $# -eq 4 ]; then
			add_group "$4"
			exit 1
		else
			echo "Usage: pick.sh host add group {group_name}"
			exit 1
		fi
	else
		echo "Usage: pick.sh host add {group | host} {group_name | host_name host_user@host_ip }"
		exit 1
	fi
elif [ "$1" == "host" ] && [ "$2" == "edit" ]; then
	code $CONFIG_FILE
elif [ "$1" == "host" ] && [ "$2" == "help" ]; then
	echo "Usage: pick.sh host {add | edit | help}"]
elif [ "$1" == "host" ] && [ "$2" == "remove" ]; then
	if [ "$3" == "host" ]
	then
		del_host
		exit 1
	elif [ "$3" == "group" ]
	then
		del_group
	else
		echo "Usage: pick.sh host remove {group | host}"
		exit 1
	fi
elif [ "$1" == "host" ]; then
	pickhost_checker
	host_selector
else
	echo "Usage: pick.sh {command}

Commands:
eks
   - Pick an EKS cluster from "$HOME/.kube/config" as the default.
   Subcommands:
	cur
		- Shows the current EKS cluster
	update <cluster name here>
		- Update kubeconfig file with new cluster by your aws creds.

aws
   - Pick an AWS profile from "$HOME/.aws/credentials" as the default.
   Subcommands:
	cur
		- Shows the current AWS profile

ns
   - Pick a K8s namespace from the default cluster as the default.
   Subcommands:
	cur
		- Shows the current K8s namespace

host
   - Pick a host to SSH into
   Subcommands:
	add
		- Adds a new host or group
		Options:
			host - Add a new host
			group - Add a new group

	edit
		- Edits the hosts file in vsCode

	remove
		- Removes an existing host or group
		Options:
			host - Remove a host
			group - Remove a group"
fi
