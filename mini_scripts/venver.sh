# #!/bin/bash

# Define the name of the virtual environment
venv_name="my_venv"

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

# Function to create the virtual environment
create_venv() {
    # Create the virtual environment
    python3 -m venv "$venv_name"
    echo "Virtual environment '$venv_name' created."
    clipboard_cmd=$(get_clipboard_command)
    if [ "$clipboard_cmd" = "Unsupported OS for clipboard copying" ]; then
        echo "Clipboard copying is not supported on this OS."
    else
        echo "source "$venv_name/bin/activate"" | $clipboard_cmd
        echo "Source CMD copied to clipboard."
        echo "Please paste it in your terminal to activate the virtual environment."
    fi
}

# Function to remove the virtual environment
remove_venv() {
    # Remove the virtual environment directory
    if [[ -d "$venv_name" ]]; then
        echo "Execute the following commands to remove the virtual environment:\n"
        echo "deactivate"
        echo "rm -rf $venv_name"
    else
        echo "Virtual environment '$venv_name' does not exist."
    fi
}

# Check the arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [-c | -r]"
    echo "  -c : Create the virtual environment"
    echo "  -r : Remove the current virtual environment"
    exit 1
fi

# Parse the arguments
while getopts "cr" option; do
    case $option in
        c) create_venv ;;
        r) remove_venv ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

exit 0
