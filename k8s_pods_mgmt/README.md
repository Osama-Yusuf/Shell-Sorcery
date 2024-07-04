# Kubernetes Pod Management Script

This script helps you manage Kubernetes pods in a specific namespace. You can list, log, or describe pods based on the given arguments.

## Usage

* **No arguments:**
    
    ```bash
    ./script.sh
    ```
    
    This will prompt you to select a namespace and microservice interactively.
    
* **Two arguments:**
    
    ```bash
    ./script.sh <namespace> <microservice>
    ```
    
    This lists all pods for the specified microservice in the given namespace.
    
* **Three arguments:**
    
    ```bash
    ./script.sh <namespace> <microservice> <get | logs | describe>
    ```
    
    This performs the specified operation (`get`, `logs`, or `describe`) on the first pod of the given microservice in the specified namespace.
    

### Examples

1. **List all pods for a microservice in a namespace:**
    
    ```bash
    ./script.sh dev books
    ```
    
    This command lists all `books` pods in the `dev` namespace.
    
2. **Log the first pod of a microservice in a namespace:**
    
    ```bash
    ./script.sh dev books logs
    ```
    
    This command logs the first `books` pod in the `dev` namespace.
    
3. **Describe the first pod of a microservice in a namespace:**
    
    ```bash
    ./script.sh dev books describe
    ```
    
    This command describes the first `books` pod in the `dev` namespace.
    

## Functions

* **show_help()**: Displays usage information.
* **pod_names()**: Retrieves pod names based on namespace and microservice.
* **first_pod_name()**: Retrieves the first pod name based on namespace and microservice.
* **get_pods()**: Lists pods for the given namespace and microservice.
* **log_pod()**: Logs the first pod for the given namespace and microservice.
* **describe_pod()**: Describes the first pod for the given namespace and microservice.
* **no_args_passed()**: Interactively selects namespace and microservice if no arguments are passed.
* **main()**: Main function to handle argument parsing and function calls.

## Notes

* Ensure you have the necessary permissions to run `kubectl` commands.
* The script assumes `kubectl` is installed and configured to interact with your Kubernetes cluster.
* Modify the script as needed to fit your specific requirements.
