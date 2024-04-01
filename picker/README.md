# Shell-Sorcery

<div align="center">
    <img src="../wizard.png" alt="Profile Image" style="border-radius: 50%; width: 300px; height: 300px; object-fit: cover;">
</div>

# Picker: DevOps Utility Script

## Overview

The Pick script is a comprehensive tool designed to streamline the process of managing SSH connections, Kubernetes contexts, AWS profiles, and more. It automates the selection and configuration of various environments, making it easier for DevOps engineers and system administrators to navigate and control their infrastructure.

## Features

* **Dynamic Host SSH**: Utilize `pickhost` and `fzf` for intuitive and interactive SSH host selection.
* **Environment Compatibility**: Supports both Linux and macOS, with conditional logic to handle system-specific configurations.
* **Kubernetes Integration**: Easily switch between Kubernetes namespaces and EKS clusters.
* **AWS Profile Management**: Select and set AWS profiles directly from the command line.
* **Extensible Configuration**: Add, remove, and manage host groups and individual hosts.

## Prerequisites

* Python 3 
* Kubernetes CLI (`kubectl`) for Kubernetes features
* AWS CLI for AWS profile management

## Installation

Ensure you have the necessary tools (`kubectl`, AWS CLI) installed. The script will attempt to install `pickhost`, `fzf` if they're not present.

## Usage

The script can be executed with various commands and options:

### General Syntax

```bash
./pick.sh [command] [options]
```

### Commands

* `eks`: Manage Kubernetes (EKS) contexts
    * `cur`: Show current EKS context
    * `update [cluster name]`: Update kubeconfig for a specific cluster
* `aws`: Manage AWS profiles
    * `cur`: Show current AWS profile
* `ns`: Manage Kubernetes namespaces
    * `cur`: Show current namespace
* `host`: SSH host management
    * `add`: Add a new host or group
    * `edit`: Edit the hosts file in VS Code
    * `remove`: Remove an existing host or group

### Examples

* Switch to a specific AWS profile:
    
    ```bash
    ./pick.sh aws
    ```
    
* Select a Kubernetes namespace:
    
    ```bash
    ./pick.sh ns
    ```
    
* Add a new host:
    
    ```bash
    ./pick.sh host add host <host_name> <user>@<host_ip>
    ```

## Testing

These script has been thoroughly tested on Ubuntu and macOS, ensuring compatibility and performance on these operating systems.

## Contributing

Contributions to improve these script or add new features are welcome. Please submit a pull request or raise an issue in the project's repository.

## License

This project is licensed under the MIT License. See the LICENSE file in the project repository for full license text.