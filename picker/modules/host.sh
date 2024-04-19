# // Function to select a host for sshing into based on the entries in the ~/.config/pickhost/hosts file.
ssh_host() {
	# pickhost an opensource project for sshing into hosts & this where you write your hosts ~/.config/pickhost/hosts and is better than using fzf with .ssh/host like above
    unset PH_NAME PH_USER PH_HOST
    eval $(pickhost 2>&1 >/dev/tty)
    # Return if no entry is selected.
    [[ -n $PH_NAME ]] || return 0
    echo -e "Logging into ${PH_NAME}...\n"
    ssh ${PH_USER}@${PH_HOST}
}

scp_host() {
	# check if three args were giving
	if [ $# -ne 3 ]; then
		echo "Usage: pick.sh host scp {to | from} {source} {destination}"
		echo "from=from host & to=to host"
		exit 1
	fi

	# pickhost an opensource project for sshing into hosts & this where you write your hosts ~/.config/pickhost/hosts and is better than using fzf with .ssh/host like above
	unset PH_NAME PH_USER PH_HOST
	eval $(pickhost 2>&1 >/dev/tty)
	# Return if no entry is selected.
	[[ -n $PH_NAME ]] || return 0
	
    local to_or_from=$1
    local source=$2
    local destination=$3

	if [ "$to_or_from" = "to" ]; then
		echo -e "Copying ${PH_NAME}...\n"
		scp -r ${source} ${PH_USER}@${PH_HOST}:${destination}
	elif [ "$to_or_from" = "from" ]; then
		echo -e "Copying ${PH_NAME}...\n"
		scp -r ${PH_USER}@${PH_HOST}:${source} ${destination}
	else
		echo "Usage: pick.sh host scp {to | from} {source} {destination}"
		echo "from=from host & to=to host"
		exit 1
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
	# Check if OS is Darwin (macOS) or Linux
	if [ "$OS" = "Darwin" ]; then
		# macOS specific sed command
		sed -i '' "/^\[$group\]/a\\
$host_name = $host_user_IP" "$CONFIG_FILE"
	elif [ "$OS" = "Linux" ]; then
		# Check if we are on Ubuntu or Debian
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
				# Ubuntu or Debian specific sed command
				sed -i "/^\[$group\]/a $host_name = $host_user_IP" "$CONFIG_FILE"
			fi
		fi
	fi
    echo -e "\nHost added to $group group (make sure to add your public key to the host authorized_keys file)"
}

add_group() {
	local group=$1
	# Check if the file does not exist
	if [ ! -f "$CONFIG_FILE" ]; then
		# Create the directory - it won't do anything if the directory already exists
		mkdir -p "$(dirname "$CONFIG_FILE")"
		
		# Create the file
		touch "$CONFIG_FILE"
	fi
	# Check if the group exists, if not create it
	if ! grep -q "\[$group\]" "$CONFIG_FILE"; then
		# Now append to the file
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

		if [ "$OS" = "Darwin" ]; then
			# macOS specific sed command
			sed -i '' "/^\[$group\]/,/^\[.*\]/d" "$CONFIG_FILE"
		elif [ "$OS" = "Linux" ]; then
			# Check if we are on Ubuntu or Debian
			if [ -f /etc/os-release ]; then
				. /etc/os-release
				if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
					sed -i "/^\[$group\]/,/^\[.*\]/d" "$CONFIG_FILE"
				fi
			fi
		fi
		echo "Group $group deleted."
	fi
}

del_host(){
	unset PH_NAME PH_USER PH_HOST
	eval $(pickhost 2>&1 >/dev/tty)
	# Return if no entry is selected.
	# [[ -n $PH_NAME ]] || return 0
	echo -e "Deleting ${PH_NAME}...\n"
	if [ "$OS" = "Darwin" ]; then
		# macOS specific sed command
		sed -i '' "/$PH_NAME/d" "$CONFIG_FILE"
	elif [ "$OS" = "Linux" ]; then
		# Check if we are on Ubuntu or Debian
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
				sed -i "/$PH_NAME/d" "$CONFIG_FILE"
			fi
		fi
	fi
	echo "Host $PH_NAME deleted."
}