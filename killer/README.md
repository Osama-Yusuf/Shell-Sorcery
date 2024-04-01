# Shell-Sorcery

<div align="center">
    <img src="../wizard.png" alt="Profile Image" style="border-radius: 50%; width: 300px; height: 300px; object-fit: cover;">
</div>

# Killer: Resource Management Utility Script

## Overview

Killer provides tools to manage system resources, including processes and Docker containers. It allows users to identify and kill processes using a specific port, manage resource-intensive processes, and clean up Docker environments.

## Features

* Kill processes occupying a specific port
* Terminate the most resource-consuming processes based on CPU or memory usage
* Manage Docker containers and images, including batch removal and cleaning up unused resources

## Prerequisites

* `netstat` or `lsof` for identifying processes by port
* `ps` for process management
* Docker for container and image management
* `fzf` for interactive selection in Docker management

## Installation

No special installation is required for the script itself, but ensure that all prerequisite tools are installed on your system.

## Usage

### General Syntax

```css
./killr.sh [option] [arguments]
```

### Options

* `port <port-number>`: Identifies and offers to kill the process occupying the specified port.
* `res <cpu|mem>`: Identifies and offers to kill the process consuming the most CPU or memory.
* `dock [docker-options]`: Provides various Docker container and image management commands.

### Docker Options

* `-n, --none`: Remove all images and containers with no tag.
* `-l, --last`: Remove the last created Docker image.
* `-e, --exited`: Remove all containers that have exited.
* `-ct, --created`: Remove all containers that are created but not running.
* `-i, --image`: Remove a specific image by ID.
* `-c, --container`: Remove specific container(s) by ID.
* `-k, --kill`: Kill specific container(s) by ID.

### Examples

* To kill the process using port 8080:
    
    ```bash
    ./killr.sh port 8080
    ```
    
* To kill the most CPU-intensive process:
    
    ```bash
    ./killr.sh res cpu
    ```
    
* To remove the last created Docker image:
    
    ```bash
    ./killr.sh dock --last
    ```

## Testing

These script has been thoroughly tested on Ubuntu and macOS, ensuring compatibility and performance on these operating systems.

## Contributing

Contributions to improve these script or add new features are welcome. Please submit a pull request or raise an issue in the project's repository.

## License

This project is licensed under the MIT License. See the LICENSE file in the project repository for full license text.