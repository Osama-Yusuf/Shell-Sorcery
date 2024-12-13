# Shell-Sorcery 

<div align="center">
    <img src="./wizard.png" alt="Profile Image" style="border-radius: 50%; width: 300px; height: 300px; object-fit: cover;">
</div>

# Picker: DevOps Utility Script

## Overview

The Pick script is a comprehensive tool designed to streamline the process of managing SSH connections, Kubernetes contexts, AWS profiles, and more. It automates the selection and configuration of various environments, making it easier for DevOps engineers and system administrators to navigate and control their infrastructure.

## Features

- **Dynamic Host SSH**: Utilize `pickhost` and `fzf` for intuitive and interactive SSH host selection.
- **Environment Compatibility**: Supports both Linux and macOS, with conditional logic to handle system-specific configurations.
- **Kubernetes Integration**: Easily switch between Kubernetes namespaces and EKS clusters.
- **AWS Profile Management**: Select and set AWS profiles directly from the command line.
- **Extensible Configuration**: Add, remove, and manage host groups and individual hosts.
- **Cross-Platform Compatibility**: Supports different commands based on the operating system, specifically tailored for macOS and Linux (Ubuntu or Debian).

## Prerequisites

- Python3
- Kubernetes CLI (`kubectl`) for Kubernetes features
- AWS CLI for AWS profile management
- The script will attempt to install `pickhost`, `fzf` if they're not present.

## Installation

```bash
# 1. Make the script executable by running:
chmod +x pick.sh
# 2. Copy it to your bin dir
sudo cp pick.sh /usr/local/bin/pick
```

## Usage

The script can be executed with various commands and options:

```bash
pick [command] [options]
```

### Commands

- `eks`: Manage Kubernetes (EKS) contexts
  - `cur`: Show current EKS context
  - `update [cluster name]`: Update kubeconfig for a specific cluster
- `aws`: Manage AWS profiles
  - `cur`: Show current AWS profile
- `ns`: Manage Kubernetes namespaces
  - `cur`: Show current namespace
- `host`: SSH host management
  - Without any option you will select a host to ssh in
  - `scp`: Securly copy files from local to host and vice versa
  - `add`: Add a new host or group
  - `edit`: Edit the hosts file in VS Code
  - `remove`: Remove an existing host or group

### Examples

- Switch to a specific AWS profile:
  ```bash
  pick aws
  ```
- Select a Kubernetes namespace:
  ```bash
  pick ns
  ```
- Add a new host:
  ```bash
  pick host add host <host_name> <user>@<host_ip>
  ```

---

# Killer: Resource Management Utility Script

## Overview

Killer provides tools to manage system resources, including processes and Docker containers. It allows users to identify and kill processes using a specific port, manage resource-intensive processes, and clean up Docker environments.

## Features

- Kill processes occupying a specific port
- Terminate the most resource-consuming processes based on CPU or memory usage
- Manage Docker containers and images, including batch removal and cleaning up unused resources

## Prerequisites

- `netstat` or `lsof` for identifying processes by port
- `ps` for process management
- Docker for container and image management
- `fzf` for interactive selection in Docker management

## Installation

```bash
# 1. Make the script executable by running:
chmod +x killr.sh
# 2. Copy it to your bin dir
sudo cp killr.sh /usr/local/bin/kil
```

## Usage

```bash
kil [option] [arguments]
```

### Options

- `port <port-number>`: Identifies and offers to kill the process occupying the specified port.
- `res <cpu|mem>`: Identifies and offers to kill the process consuming the most CPU or memory.
- `dock [docker-options]`: Provides various Docker container and image management commands.

### Docker Options

- `-n, --none`: Remove all images and containers with no tag.
- `-l, --last`: Remove the last created Docker image.
- `-e, --exited`: Remove all containers that have exited.
- `-ct, --created`: Remove all containers that are created but not running.
- `-i, --image`: Remove a specific image by ID.
- `-c, --container`: Remove specific container(s) by ID.
- `-k, --kill`: Kill specific container(s) by ID.

### Examples

- To kill the process using port 8080:
  ```bash
  kil port 8080
  ```
- To kill the most CPU-intensive process:
  ```bash
  kil res cpu
  ```
- To remove the last created Docker image:
  ```bash
  kil dock --last
  ```

---

# LockSafee: Secure Shell Password Manager 🛡️

## Welcome to LockSafe: Your Secure Shell Password Manager 🛡️

#### 🌟 Features of LockSafe

- **Session PIN Lock** 🔐: LockSafe secures your session using a PIN. Once unlocked, the session remains open until you exit, so no need to re-enter the PIN constantly.
- **Encryption** 🔒: Utilizes AES-256 encryption with PBKDF2 enhancement for your password file, ensuring top-level security.
- **Ease of Use** 🎉: Simple command-line interface for adding, retrieving, and managing passwords.
- **Clipboard Support** 📋: Easily copy passwords to your clipboard on retrieval for convenient use.
- **OS Compatibility** 💻: Custom clipboard commands for different operating systems ensure seamless user experience across platforms.

#### Getting Started with LockSafe 🚀

1. **Initial Setup**

   - Download or clone the repository.
   - Open your terminal and navigate to the repository directory.
   - Run the script with your desired PIN:
     ```bash
     ./setup.sh -p YOUR_PIN_HERE
     ```
   - This creates an encrypted file `passwords.enc`, securely storing your passwords.

2. **Using LockSafe**

   - Run the password manager script:
     ```bash
     ./pwd_mgr.sh
     ```
   - Follow the on-screen prompts to manage your passwords:
     ```text
     LockSafe Menu:
     1. Add a new password
     2. Retrieve a password
     3. List all users
     4. Quit
     Choose an option (1-4):
     ```

#### Developer Notes 🛠️

- For manual decryption (for testing only):
  ```bash
  ./setup.sh -d YOUR_PIN_HERE
  ```

#### Contribute 🌐

- Contributions are welcome! Fork the repository and submit pull requests to help improve LockSafe.

Feel free to start managing your passwords more securely with LockSafe today! 🌟

---

# Mini Scripts

# - Git Helper

## Overview

This script makes it faster and easier to push new code to a centralized repo like github, gitlab and more with one command no need to write the common sequence of commands to push new code.

## Features

- **Repository Validation**: Automatically checks if the current directory is part of a Git repository before performing any operations.
- **GitHub Link Opener**: Opens the GitHub link associated with the current repository in your default browser.
- **Easy Git Push**: Allows easy staging, committing, and pushing changes by providing a single command that accepts a commit message.
- **Cross-Platform Compatibility**: Supports different commands based on the operating system, specifically tailored for macOS and Linux (Ubuntu or Debian).

## Installation

```bash
# 1. Make the script executable by running:
chmod +x get.sh
# 2. Copy it to your bin dir
sudo cp get.sh /usr/local/bin/get
```

## Usage

To use this script, you must have Git installed on your machine. Here are the commands you can use:

- **Push Changes**:
  Run the script with `push` followed by your commit message to add, commit, and push changes to the current branch of your repository.
  You can type your commit message with/without quotation marks

```bash
get push Your commit message here
# Or like this as well
get push "Your commit message here"
```

- **Open GitHub Link**:
  Use the `link` command to open the GitHub repository URL associated with the current directory in your default web browser.

```bash
get link
```

# - NukeNode: Node Modules Cleaner

## Overview

This Python script is designed to help developers clean up `node_modules` directories from their project folders. It recursively searches through a specified directory (default set to the user's OneDrive folder) and deletes any `node_modules` directories it finds. This can help in reclaiming disk space and tidying up development environments.

## Features

- **Recursive Search**: Automatically scans directories and subdirectories starting from a specified path for `node_modules` directories.
- **Error Handling**: Includes an error handler for the `shutil.rmtree` function, which is used to remove directories. If a directory cannot be removed because it contains read-only files, the script attempts to change the file permissions and retries the deletion.
- **Customizable Starting Directory**: By default, the search starts in the user's OneDrive directory, but this can be easily modified in the script.

## Usage

To use this script, you need Python 3 installed on your machine. Follow these steps:

1. **Prepare the Script**:

   - Optionally, modify the `search_dir` variable in the script to the path where you want the search to begin.
   - Make the script executable and then copy it to your bin dir
     ```bash
        chmod +x nukenode.sh
        sudo cp nukenode.sh /usr/local/bin/nukenode
     ```

2. **Run the Script**:

   - Execute the script by running:
     ```bash
        nukenode
     ```

3. **Monitor Output**:
   - The script prints messages to the console as it finds and deletes `node_modules` directories.

### ToDo

- [ ] Add folder passing as an argument and if not passed use the default hard codded value in the script
- [ ] Prompt the user before changing any file/dirs permissions

### Note:

Be cautious with the directories you target for cleaning as this script will delete all contents of any `node_modules` directory it finds, which might affect project dependencies if not intended for deletion.

Make sure to review the paths and confirm deletions if modifying the script for broader or more specific use.

# - K8s Deployment Validator

## Overview

This Bash script assists Kubernetes administrators and DevOps engineers in verifying that the deployed microservices in a Kubernetes namespace contain the correct image tags corresponding to specific pipeline commits. The script facilitates the selection of a namespace and a microservice, then it checks and reports whether the image tags of the pods in the selected microservice match the expected pipeline commits.

## Features

- **Interactive Namespace and Microservice Selection**: Users can choose a namespace and a microservice from dynamically generated lists, ensuring that checks are performed against current deployments.
- **Commit Hash Validation**: For each pod associated with the chosen microservice, the script extracts and displays the image tag used, which should include the commit hash from the CI/CD pipeline that built and deployed the image.
- **Enhanced Deployment Tracking**: This tool is particularly useful for tracking the deployment status and ensuring that only the correct, approved versions of software are running in specified environments.

## Usage

Ensure that `kubectl` is installed and configured correctly to communicate with your Kubernetes cluster. Here are the detailed steps to run this script:

1. **Prepare the Script**:

   - Make the script executable and move it to your bin dir by running:
     ```bash
        chmod +x k8s_img_valid.sh
        sudo cp k8s_img_valid.sh /usr/local/bin/imgchk # Other cool names depchk/depvfy/k8svfy/tagvfy/tagchk/imgvfy
     ```

2. **Run the Script**:

   - Open a terminal.
   - Navigate to the directory containing the script.
   - Start the script by executing:
     ```
     imgchk
     ```

3. **Interactive Prompts**:
   - Follow the on-screen prompts to select a namespace from the listed options.
   - Choose a microservice deployment. The script simplifies Kubernetes deployment names for easier selection.
   - The script will display information about each pod, specifically focusing on the image tag, to verify it includes the commit hash of the pipeline that deployed it.

## Testing

These script has been thoroughly tested on Ubuntu and macOS, ensuring compatibility and performance on these operating systems.

## Contributing

Contributions to improve these script or add new features are welcome. Please submit a pull request or raise an issue in the project's repository.

## License

This project is licensed under the MIT License. See the LICENSE file in the project repository for full license text.
