#!/bin/bash

# Initialize session
if [[ "$SESSION_UNLOCKED" != "true" ]]; then
    read -sp "Enter your PIN to unlock the session: " PIN
    echo
fi

# File variables
encrypted_file="passwords.enc"
plain_file="passwords.txt"  

# Decrypt the password file
decrypt_file() {
    if [ -e "$encrypted_file" ]; then
        # Attempt to decrypt and check for errors
        # decryption_output=$(openssl enc -aes-256-cbc -d -in "$encrypted_file" -out "$plain_file" -pass pass:$PIN 2>&1)
        decryption_output=$(openssl enc -aes-256-cbc -d -pbkdf2 -in "$encrypted_file" -out "$plain_file" -pass pass:$PIN 2>&1)
        if echo "$decryption_output" | grep -q "bad decrypt"; then
            echo "Wrong PIN. Exiting."
            exit 1
        else
            export SESSION_UNLOCKED="true"
            export PIN=$PIN  
        fi
    else
        touch "$plain_file"
    fi
}

# Encrypt the password file only if "$plain_file" is not empty
encrypt_file() {
    openssl enc -aes-256-cbc -pbkdf2 -in "$plain_file" -out "$encrypted_file" -pass pass:$PIN
    rm "$plain_file"
}

# Decrypt the file at the start
decrypt_file

# Define function to add a password
add_password() {
    read -p "Enter the account name: " account
    read -sp "Enter the password: " password
    echo "$account: $password" >> "$plain_file"
    clear
    echo "Password added for $account."
    echo
}

# Function to determine the clipboard command based on the OS
get_clipboard_command() {
    case "$(uname)" in
        "Linux")
            echo "xclip -selection clipboard"  # Debian-based systems like Ubuntu
            ;;
        "Darwin")
            echo "pbcopy"  # macOS uses pbcopy
            ;;
        *)
            echo "Unsupported OS for clipboard copying"
            ;;
    esac
}

# Define function to retrieve a password and copy it to the clipboard
get_password() {
    read -p "Enter the account name: " account
    password=$(grep "^$account:" "$plain_file" | cut -d ":" -f2)
    if [ -n "$password" ]; then
        clear
        echo "Password for $account: $password"
        # Determine the correct clipboard command and use it
        clipboard_cmd=$(get_clipboard_command)
        if [ "$clipboard_cmd" = "Unsupported OS for clipboard copying" ]; then
            echo "Clipboard copying is not supported on this OS."
        else
            echo -n "$password" | $clipboard_cmd
            echo "Password copied to clipboard."
        fi
    else
        echo "Password not found for $account."
    fi
    echo
}

# Define function to list all users
list_users() {
    clear
    echo "Current users:"
    cut -d ":" -f1 "$plain_file"
    echo
}

quit() {
    encrypt_file
    # check if script is source or not if not reload bash to save changes like "cd dirctory"
    if [ "$0" = "$BASH_SOURCE" ]; then
        $SHELL
    fi
    exit 0
}

# Handle script exit, interruptions and Ctrl+C
trap quit SIGINT

# Main menu
while true; do
    echo
    echo "LockSafe Menu:"
    echo "1. Add a new password"
    echo "2. Retrieve a password"
    echo "3. List all users"
    echo "4. Quit"

    read -p "Choose an option (1-4): " choice
    case $choice in
        1) add_password;;
        2) get_password;;
        3) list_users;;
        4) quit;;
        *) echo "Invalid option";;
    esac
done