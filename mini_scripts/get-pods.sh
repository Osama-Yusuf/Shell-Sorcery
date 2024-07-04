#!/bin/bash

show_help() {
    echo "Usage: $0 <namespace> <microservice>"
    echo "Example: $0 dev books"
    echo "Please provide two arguments."
}

no_args_passed() {
    # Retrieve a list of namespaces from Kubernetes and store them in an array
    namespaces=$(kubectl get namespace -o=jsonpath='{.items[*].metadata.name}')
    IFS=' ' read -r -a namespaces_array <<< "$namespaces"

    # Prompt the user to select a namespace from the list
    echo "Please select a namespace "

    # Provide a selection mechanism for the namespace array
    select chosen_namespace in "${namespaces_array[@]}"; do
        # Check if a namespace was selected
        if [[ -n "$chosen_namespace" ]]; then
            echo -e "\nYou have selected $chosen_namespace namespace"
            break # Break the loop if selection is valid
        else
            echo "invalid" # Indicate invalid selection
        fi
    done

    # Retrieve a list of deployments from Kubernetes and store them in an array
    microservices=$(kubectl get deployments -o=jsonpath='{.items[*].metadata.name}')
    IFS=' ' read -r -a microservices_array <<< "$microservices"

    # Process each microservice to cut by "-"
    for i in "${!microservices_array[@]}"; do
        # Use Bash substring removal instead of cut for better integration in the script
        microservices_array[i]="${microservices_array[i]%%-*}"
    done

    # Prompt the user to select a namespace from the list
    echo -e "\nPlease select a microservice "

    # Provide a selection mechanism for the namespace array
    select microservice in "${microservices_array[@]}"; do
        # Check if a microservice was selected
        if [[ -n "$microservice" ]]; then
            echo -e "\nYou have selected $microservice microservice\n"
            break # Break the loop if selection is valid
        else
            echo "invalid" # Indicate invalid selection
        fi
    done
}

logic() {
    # Retrieve a list of pods from the selected namespace that match the microservice name
    kubectl get pods -n $chosen_namespace | grep $microservice
}

main() {
    if [ "$#" -eq 0 ]; then
        no_args_passed
        logic
    elif [ "$#" -eq 2 ]; then
        chosen_namespace=$1
        microservice=$2
        logic "$chosen_namespace" "$microservice"
    else
        show_help
    fi
}
main "$@"
