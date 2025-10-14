#!/bin/bash

source ./modules/dependencies.sh
source ./modules/aws.sh
source ./modules/host.sh
source ./modules/pod.sh
source ./modules/context.sh

# execute set-x if got --debug flag at any position as argument
if [[ "$*" == *--debug* ]]
then
	set -x
fi

# Determine the OS type
OS=$(uname -s)

# ---------------- get hosts from .ssh/config then ssh into it --------------- #
# host=$(cat .ssh/config | grep "Host " | grep -v "#" | awk '{print $2}' | fzf)
# ssh $host
# ---------------------------------------------------------------------------- #

if [ "$OS" = "Darwin" ]; then
	# macOS specific sed command
	CONFIG_FILE="$HOME/Library/Application Support/pickhost/config/pickhost/hosts"
elif [ "$OS" = "Linux" ]; then
	# Check if we are on Ubuntu or Debian
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
			# update the existing AWS_PROFILE value
			CONFIG_FILE=~/.config/pickhost/hosts
		fi
	fi
fi

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

namespace_argument_handler() {
	local target_namespace="$1"
	
	# Check if the provided namespace exists
	if kubectl get namespace "$target_namespace" &> /dev/null; then
		echo "Switching to namespace: $target_namespace"
		kubectl config set-context --current --namespace="$target_namespace"
		exit 0
	else
		echo "Namespace '$target_namespace' doesn't exist."
		
		# Get all available namespaces and find similar ones
		local available_namespaces=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")
		local similar_namespaces=$(echo "$available_namespaces" | grep -i "$target_namespace" | head -3)
		
		if [ -n "$similar_namespaces" ]; then
			echo "Did you mean one of these?"
			echo "$similar_namespaces"
			echo ""
			echo "Options:"
			echo "  Y - Switch to a suggested namespace"
			echo "  F - Open fzf menu to select from all namespaces"
			echo "  N - Exit"
		else
			echo "No similar namespaces found."
			echo ""
			echo "Options:"
			echo "  F - Open fzf menu to select from all namespaces"
			echo "  N - Exit"
		fi
		
		echo ""
		if [ -n "$similar_namespaces" ]; then
			read -p "Your choice (Y/F/N): " choice
		else
			read -p "Your choice (F/N): " choice
		fi
		
		case "$choice" in
			[Yy]*)
				if [ -n "$similar_namespaces" ]; then
					# If only one similar namespace, use it directly
					local namespace_count=$(echo "$similar_namespaces" | wc -l)
					if [ "$namespace_count" -eq 1 ]; then
						local selected_namespace="$similar_namespaces"
						echo "Switching to namespace: $selected_namespace"
						kubectl config set-context --current --namespace="$selected_namespace"
					else
						# Multiple similar namespaces, let user pick with fzf
						fzf_checker
						local selected_namespace=$(echo "$similar_namespaces" | fzf --cycle --reverse --height 50% --border --prompt "Select a namespace: " --preview "echo {}" --preview-window down:1:wrap)
						if [ -n "$selected_namespace" ]; then
							echo "Switching to namespace: $selected_namespace"
							kubectl config set-context --current --namespace="$selected_namespace"
						else
							echo "No namespace selected"
							exit 1
						fi
					fi
				else
					echo "No suggestions available"
					exit 1
				fi
				;;
			[Ff]*)
				fzf_checker
				namespace_selector
				;;
			[Nn]*)
				echo "Exiting"
				exit 0
				;;
			*)
				echo "Invalid choice. Exiting"
				exit 1
				;;
		esac
	fi
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
	if [ "$2" == "edit" ]
	then
		aws_editor
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
	elif [ -n "$2" ]
	then
		namespace_argument_handler "$2"
	else
		# No second argument provided, use fzf selector
		fzf_checker
		namespace_selector
	fi
elif [ "$1" == "pod" ]
then
	if [ -z "$2" ]
	then
		# Default: show saved entries and exec into selected pod
		pod_exec
		exit 1
	elif [ "$2" == "cur" ]
	then
		pod_current_context
		exit 1
	elif [ "$2" == "add" ]
	then
		pod_add
		exit 1
	elif [ "$2" == "list" ]
	then
		pod_list
		exit 1
	else
		echo "Usage: pick.sh pod {add | cur | list}"
		exit 1
	fi
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
	code "$CONFIG_FILE"
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
elif [ "$1" == "host" ] && [ "$2" == "scp" ]; then
	# check if three args were giving
	if [ $# -ne 5 ]; then
		echo "Usage: pick.sh host scp {to | from} {source} {destination}"
echo "from=from host & to=to host"
		exit 1
	fi
	pickhost_checker
	scp_host "$3" "$4" "$5"
elif [ "$1" == "host" ]; then
	pickhost_checker
	ssh_host
elif [ "$1" == "context" ]
then
	if [ "$2" == "cur" ]
	then
		kubectl config current-context
		exit 1
	elif [ -n "$2" ]
	then
		context_argument_handler "$2"
	else
		# No second argument provided, use fzf selector
		fzf_checker
		context_selector
	fi
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
	edit
		- Edit the current AWS configuration file
	cur
		- Shows the current AWS profile

ns
   - Pick a K8s namespace from the default cluster as the default.
   Subcommands:
	cur
		- Shows the current K8s namespace

pod
   - Save and exec into K8s pods by friendly name.
   Subcommands:
       cur
           - Shows the current K8s context
       add
           - Pick ns -> pod with fzf, name it, choose shell, and save (name - ns - context)
       list
           - List saved pod entries
   Default behavior without subcommand:
       - Show saved entries; ensure context matches or prompt to switch; execs into pod with saved shell

host
   - Pick a host to SSH into
   Subcommands:
    scp
		- Copy files from or to a host
		Options:
			to/from - Copy to or from a host
			source - Source file
			destination - Destination path
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
			group - Remove a group

context
   - Pick a Kubernetes context from kubeconfig
   Subcommands:
	cur
		- Shows the current Kubernetes context
   Default behavior without subcommand:
	- Shows fzf menu to select context
   With context name argument:
	- Switches directly to specified context"
fi