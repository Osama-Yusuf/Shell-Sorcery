#!/bin/bash

show_help() {
    echo "Usage: $0 <namespace> <microservice>"
    echo "Usage: $0 <namespace> <microservice> <get || logs || describe>"
    echo
    echo -e "Example: $0 dev books\nThis will list all book pods in the dev namespace\n"
    echo -e "Example: $0 dev books logs\nThis will log the first book pod in the dev namespace\n"
    echo -e "Example: $0 dev books describe\nThis will describe the first book pod in the dev namespace"
    echo
    echo "Please provide at least two or three arguments."
}

pod_names() {
    chosen_namespace=$1
    # microservice is below renamed to POD
    POD=$2
    DEPLOY_NAME=$(kubectl get deploy -n ${chosen_namespace} | grep "\b${POD}\b" | awk '{print $1}')
    RS_NAME=`kubectl describe deployment $DEPLOY_NAME -n ${chosen_namespace} | grep "^NewReplicaSet"|awk '{print $2}'`
    POD_HASH_LABEL=`kubectl get rs $RS_NAME -n ${chosen_namespace} -o jsonpath="{.metadata.labels.pod-template-hash}"`
    POD_NAMES=`kubectl get pods -n ${chosen_namespace} -l pod-template-hash=$POD_HASH_LABEL --show-labels | tail -n +2 | awk '{print $1}'`
    UNFILTERED_DEPLOY_NAME=$(kubectl get deploy -n ${chosen_namespace} | grep "\b${POD}\b")
    # echo "----"
    # echo "Showing $POD deployment:"
    # echo $UNFILTERED_DEPLOY_NAME
    # echo "----"
    # echo "Showing $POD pods:"
}

first_pod_name() {
    chosen_namespace=$1
    microservice=$2
    # select a pod from POD_HASH_LABEL list
    pod_names "$chosen_namespace" "$microservice"
    first_pod_name=$(kubectl get pods -n $chosen_namespace | grep $POD_HASH_LABEL | awk 'NR==1{print $1}')
}

get_pods() {
    chosen_namespace=$1
    microservice=$2
    pod_names "$chosen_namespace" "$microservice"
    kubectl get pods -n $chosen_namespace | grep $POD_HASH_LABEL
    echo
}

log_pod() {
    chosen_namespace=$1
    microservice=$2
    first_pod_name "$chosen_namespace" "$microservice"
    kubectl logs -n $chosen_namespace $first_pod_name
}

describe_pod() {
    first_pod_name "$chosen_namespace" "$microservice"
    kubectl describe pod -n $chosen_namespace $first_pod_name
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

    get_pods "$chosen_namespace" "$microservice"

    # After showing the pods, ask if the user wants another operation like logs or describe
    echo -e "\nDo you want to perform another operation? (e.g., logs, describe)"
    read -p "Enter the operation you want to perform: " operation

    # Check the user's choice and execute the corresponding operation
    case $operation in
        logs)
            # Call a function to show logs
            log_pod "$chosen_namespace" "$microservice"
            ;;
        describe)
            # Call a function to describe the selected pod
            describe_pod "$chosen_namespace" "$microservice"
            ;;
        *)
            echo "Invalid operation. Exiting."
            ;;
    esac
}

main() {
    if [ "$#" -eq 0 ]; then
        no_args_passed
    elif [ "$#" -eq 2 ]; then
        chosen_namespace=$1
        microservice=$2
        get_pods "$chosen_namespace" "$microservice"
    elif [ "$#" -eq 3 ]; then
        chosen_namespace=$1
        microservice=$2
        if [ "$3" == "get" ]; then
            get_pods "$chosen_namespace" "$microservice"
        elif [ "$3" == "logs" ]; then
            log_pod "$chosen_namespace" "$microservice"
        elif [ "$3" == "describe" ]; then
            describe_pod "$chosen_namespace" "$microservice"
        else
            show_help
        fi
    else
        show_help
    fi
}
main "$@"
