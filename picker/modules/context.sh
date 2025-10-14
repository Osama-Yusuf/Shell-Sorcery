context_selector() {
	# Get context names only
	selected_context=$(kubectl config get-contexts -o name | fzf --cycle --reverse --height 50% --border --prompt "Select a context: " --preview "echo {}" --preview-window down:1:wrap)
	
	# Check if a context was selected
	if [ -z "$selected_context" ]; then
		echo "No context selected. Exiting."
		exit 1
	fi
	
	kubectl config use-context "$selected_context"
	echo "Switched to context: $selected_context"
}

context_argument_handler() {
	local target_context="$1"
	
	# Get all available contexts
	local available_contexts=$(kubectl config get-contexts --no-headers -o name)
	
	# Check if the provided context exists
	if echo "$available_contexts" | grep -q "^${target_context}$"; then
		echo "Switching to context: $target_context"
		kubectl config use-context "$target_context"
		exit 0
	else
		echo "Context '$target_context' doesn't exist."
		
		# Find similar contexts
		local similar_contexts=$(echo "$available_contexts" | grep -i "$target_context" | head -3)
		
		if [ -n "$similar_contexts" ]; then
			echo "Did you mean one of these?"
			echo "$similar_contexts"
			echo ""
			echo "Options:"
			echo "  Y - Switch to a suggested context"
			echo "  F - Open fzf menu to select from all contexts"
			echo "  N - Exit"
		else
			echo "No similar contexts found."
			echo ""
			echo "Options:"
			echo "  F - Open fzf menu to select from all contexts"
			echo "  N - Exit"
		fi
		
		echo ""
		if [ -n "$similar_contexts" ]; then
			read -p "Your choice (Y/F/N): " choice
		else
			read -p "Your choice (F/N): " choice
		fi
		
		case "$choice" in
			[Yy]*)
				if [ -n "$similar_contexts" ]; then
					# If only one similar context, use it directly
					local context_count=$(echo "$similar_contexts" | wc -l)
					if [ "$context_count" -eq 1 ]; then
						local selected_context="$similar_contexts"
						echo "Switching to context: $selected_context"
						kubectl config use-context "$selected_context"
					else
						# Multiple similar contexts, let user pick with fzf
						fzf_checker
						local selected_context=$(echo "$similar_contexts" | fzf --cycle --reverse --height 50% --border --prompt "Select a context: " --preview "echo {}" --preview-window down:1:wrap)
						if [ -n "$selected_context" ]; then
							echo "Switching to context: $selected_context"
							kubectl config use-context "$selected_context"
						else
							echo "No context selected"
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
				context_selector
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
