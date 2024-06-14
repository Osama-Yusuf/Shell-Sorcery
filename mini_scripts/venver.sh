# #!/bin/bash

# Define the name of the virtual environment
venv_name="my_venv"

# Function to create the virtual environment
create_venv() {
    # Create the virtual environment
    python3 -m venv "$venv_name"
    
    # Activate the virtual environment
    echo "Execute the following command to activate the virtual environment:\n"
    echo "source "$venv_name/bin/activate""
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
