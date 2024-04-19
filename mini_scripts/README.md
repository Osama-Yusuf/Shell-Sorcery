# Git Helper

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
``` bash
get push Your commit message here
# Or like this as well
get push "Your commit message here"
```

- **Open GitHub Link**:
Use the `link` command to open the GitHub repository URL associated with the current directory in your default web browser.
```bash
get link
```

---

# NukeNode: Node Modules Cleaner

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

---

# K8s Deployment Validator

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