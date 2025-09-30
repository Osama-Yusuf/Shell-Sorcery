#!/bin/bash

# Persistent store for saved pod entries
# macOS: ~/Library/Application Support/pickhost/config/pickhost/pods
# Linux (Ubuntu/Debian): ~/.config/pickhost/pods
pod_store_path() {
	local store=""
	if [ "$OS" = "Darwin" ]; then
		store="$HOME/Library/Application Support/pickhost/config/pickhost/pods"
	elif [ "$OS" = "Linux" ]; then
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
				store="$HOME/.config/pickhost/pods"
			fi
		fi
	fi
	echo "$store"
}

ensure_pod_store() {
	local store
	store=$(pod_store_path)
	if [ -z "$store" ]; then
		echo "Unsupported OS for pod store" >&2
		exit 1
	fi
	mkdir -p "$(dirname "$store")"
	[ -f "$store" ] || touch "$store"
}

kubectl_checker() {
	if ! command -v kubectl >/dev/null 2>&1; then
		echo "kubectl is required but not installed." >&2
		exit 1
	fi
}

# a) Get current context
pod_current_context() {
	kubectl config current-context
}

# b) Select namespace then pod, enter a friendly name, and save
pod_add() {
	kubectl_checker
	fzf_checker
	ensure_pod_store

	local context ns pod name shell store
	context=$(kubectl config current-context)
	if [ -z "$context" ]; then
		echo "No current kubectl context set." >&2
		exit 1
	fi

	# Select namespace
	ns=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | fzf --multi --cycle --reverse --height 50% --border --prompt "Select a namespace: " --preview "echo {}" --preview-window down:1:wrap)
	if [ -z "$ns" ]; then
		echo "No namespace selected" >&2
		exit 1
	fi

	# Select pod in namespace
	pod=$(kubectl get pods -n "$ns" --no-headers -o custom-columns=":metadata.name" | fzf --multi --cycle --reverse --height 50% --border --prompt "Select a pod in $ns: " --preview "kubectl get pod -n $ns {} -o yaml | sed -n '1,80p'" --preview-window down:1:wrap)
	if [ -z "$pod" ]; then
		echo "No pod selected" >&2
		exit 1
	fi

	# Enter friendly name
	read -r -p "Enter a name for this pod entry: " name
	if [ -z "$name" ]; then
		echo "Name is required" >&2
		exit 1
	fi

	# Choose and save a default shell for this pod entry
	echo -n "Shell to exec (default: sh, options: sh/bash): "
	read -r shell
	if [ -z "$shell" ]; then
		shell="sh"
	fi

	store=$(pod_store_path)
	# Format: name - ns - context - pod - shell
	# Note: user asked for name - ns - context, but we also need pod; keep pod as last for exec
	# If an entry with same name exists, replace it
	if grep -q "^$name - .* - .* - .*" "$store"; then
		# macOS sed needs backup extension; Linux sed doesn't
		if [ "$OS" = "Darwin" ]; then
			sed -i '' -e "s/^$name - .* - .* - .*/$name - $ns - $context - $pod - $shell/" "$store"
		else
			sed -i -e "s/^$name - .* - .* - .*/$name - $ns - $context - $pod - $shell/" "$store"
		fi
	else
		echo "$name - $ns - $context - $pod - $shell" >> "$store"
	fi

	echo "Saved: $name - $ns - $context"
}

# c) Select a saved entry, ensure context matches (or prompt to switch), then exec
pod_exec() {
	kubectl_checker
	fzf_checker
	ensure_pod_store

	local store cur_ctx line name ns context pod shell
	store=$(pod_store_path)
	if [ ! -s "$store" ]; then
		echo "No saved pods. Add one with: pick pod add" >&2
		exit 1
	fi

	line=$(cat "$store" | fzf --cycle --reverse --height 50% --border --prompt "Select saved pod: " --preview "echo {}" --preview-window down:1:wrap)
	if [ -z "$line" ]; then
		echo "No entry selected" >&2
		exit 1
	fi

	# Parse: name - ns - context - pod - shell (shell optional for backward compatibility)
	name=$(echo "$line" | awk -F ' - ' '{print $1}')
	ns=$(echo "$line" | awk -F ' - ' '{print $2}')
	context=$(echo "$line" | awk -F ' - ' '{print $3}')
	pod=$(echo "$line" | awk -F ' - ' '{print $4}')
	shell=$(echo "$line" | awk -F ' - ' '{print $5}')

	if [ -z "$name" ] || [ -z "$ns" ] || [ -z "$context" ] || [ -z "$pod" ]; then
		echo "Invalid entry format in store: $line" >&2
		exit 1
	fi

	cur_ctx=$(kubectl config current-context)
	if [ "$cur_ctx" != "$context" ]; then
		echo "Current context ($cur_ctx) differs from saved context ($context)."
		echo -n "Press Enter to switch to $context and continue, or press any key/Ctrl+C to cancel..."
		# Read a whole line: Enter (empty) approves, any input cancels, Ctrl+C aborts
		read -r key
		if [ -z "$key" ]; then
			kubectl config use-context "$context" || exit 1
		else
			echo "\nCancelled."
			exit 1
		fi
	fi

	# If shell not present in entry, default to sh
	if [ -z "$shell" ]; then
		shell="sh"
	fi

	echo "Exec into $name ($pod) in ns=$ns, ctx=$context"
	kubectl exec -n "$ns" -it "$pod" -- "$shell"
}

# List saved entries
pod_list() {
	ensure_pod_store
	cat "$(pod_store_path)"
}


