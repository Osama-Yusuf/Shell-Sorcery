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
        clipboard_cmd=$(get_clipboard_command)
        if [ "$clipboard_cmd" = "Unsupported OS for clipboard copying" ]; then
            echo -e "Clipboard copying is not supported on this OS.\n"
            echo "Please copy paste the following command in your terminal to remove the virtual environment."
            echo "deactivate && rm -rf $venv_name"
        else
            echo "deactivate && rm -rf $venv_name" | $clipboard_cmd
            echo "CMD copied to clipboard."
            echo "Please paste it in your terminal to remove the virtual environment."
        fi
    else
        echo "Virtual environment '$venv_name' does not exist."
    fi
}

create_requirements() {
    pip3 freeze > requirements.txt
    echo "Requirements file 'requirements.txt' created."
}

# Add 'i' argument to install requirements of current dir
install_requirements() {
    pip3 install -r requirements.txt
    echo "Requirements installed from 'requirements.txt'."
}

activate_venv() {
    if [[ -d "$venv_name" ]]; then
        clipboard_cmd=$(get_clipboard_command)
        if [ "$clipboard_cmd" = "Unsupported OS for clipboard copying" ]; then
            echo -e "Clipboard copying is not supported on this OS.\n"
            echo "Please copy paste the following command in your terminal to activate the virtual environment."
            echo "source $venv_name/bin/activate"
        else
            echo "source $venv_name/bin/activate" | $clipboard_cmd
            echo "CMD copied to clipboard."
            echo "Please paste it in your terminal to activate the virtual environment."
        fi
    else
        echo "Virtual environment '$venv_name' does not exist."
    fi
}

# Check the arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [-c | -r | -f | -i | -a]"
    echo "  -c : Create the virtual environment"
    echo "  -r : Remove the current virtual environment"
    echo "  -a : Activate the current virtual environment"
    echo "  -f : Create requirements file"
    echo "  -i : Install requirements from file"
    exit 1
fi

# Parse the arguments
while getopts "crafi" option; do
    case $option in
        c) create_venv ;;
        r) remove_venv ;;
        a) activate_venv ;;
        f) create_requirements ;;
        i) install_requirements ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

exit 0