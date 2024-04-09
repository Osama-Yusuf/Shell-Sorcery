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

	if [ "$OS" = "Darwin" ]; then
		# macOS specific sed command
		# check if AWS_PROFILE is already set in .bashrc
		if grep -q "export AWS_PROFILE=" "$HOME/.zshrc"; then
			# update the existing AWS_PROFILE value
			sed -i '' -e "s/export AWS_PROFILE=.*/export AWS_PROFILE='$selected_profile'/" "$HOME/.zshrc"
		else
			# append the export statement to .bashrc
			echo "export AWS_PROFILE=$selected_profile" >> "$HOME/.zshrc"
		fi
	elif [ "$OS" = "Linux" ]; then
		# Check if we are on Ubuntu or Debian
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
				# update the existing AWS_PROFILE value
				# check if AWS_PROFILE is already set in .bashrc
				if grep -q "export AWS_PROFILE=" "$HOME/.bashrc"; then
					# update the existing AWS_PROFILE value
					sed -i -e "s/export AWS_PROFILE=.*/export AWS_PROFILE=$selected_profile/" "$HOME/.bashrc"
				else
					# append the export statement to .bashrc
					echo "export AWS_PROFILE=$selected_profile" >> "$HOME/.bashrc"
				fi
			fi
		fi
	fi

	# source the .bashrc file to apply changes in the current session
	source "$HOME/.bashrc"

	echo "AWS profile '$selected_profile' set as the default profile."

	if [ "$0" = "$BASH_SOURCE" ]; then
		# if not sourced
		$SHELL
	fi
}

aws_editor() {
	# get the AWS editor
	code "$HOME/.aws"
}