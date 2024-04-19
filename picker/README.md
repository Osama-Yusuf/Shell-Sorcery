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

## Testing

These script has been thoroughly tested on Ubuntu and macOS, ensuring compatibility and performance on these operating systems.

## Contributing

Contributions to improve these script or add new features are welcome. Please submit a pull request or raise an issue in the project's repository.

## License

This project is licensed under the MIT License. See the LICENSE file in the project repository for full license text.
