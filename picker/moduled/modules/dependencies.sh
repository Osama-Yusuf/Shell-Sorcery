pickhost_checker() {
	# check if pickhost is installed if not install it
	if ! command -v pickhost &> /dev/null
	then
		echo "pickhost isn't installed, installing it now..."
		python3 -m pip install pickhost # https://github.com/rayx/pickhost
	fi
}

fzf_checker() {
    # check if fzf is installed, if not, install it
    if ! command -v fzf &> /dev/null; then
        echo "fzf isn't installed, installing it now..."

        # Function to execute package manager command with or without sudo
        execute() {
            if [[ $EUID -ne 0 ]]; then
                sudo $@
            else
                $@
            fi
        }

        # Determine OS and install with appropriate package manager
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux OS detected
            if [ -f /etc/debian_version ]; then
                # Debian/Ubuntu
                execute apt update
                execute apt install -y fzf
            elif [ -f /etc/redhat-release ]; then
                # RHEL/CentOS
                execute yum update
                execute yum install -y fzf
            else
                echo "Unsupported Linux distribution"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS detected
            # Check for Homebrew and install if fzf is not available
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not installed, installing now..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
            fi
            brew install fzf
        else
            echo "Unsupported operating system."
        fi
    else
        echo "fzf is already installed."
    fi
}