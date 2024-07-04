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
    POD=$2
    DEPLOY_NAME=$(kubectl get deploy -n ${chosen_namespace} | grep "\b${POD}\b" | awk '{print $1}')
    if [ -z "$DEPLOY_NAME" ]; then
        echo "No deployment found for $POD"
        exit 1
    fi
    RS_NAME=`kubectl describe deployment $DEPLOY_NAME -n ${chosen_namespace} | grep "^NewReplicaSet"|awk '{print $2}'`
    POD_HASH_LABEL=`kubectl get rs $RS_NAME -n ${chosen_namespace} -o jsonpath="{.metadata.labels.pod-template-hash}"`
    POD_NAMES=`kubectl get pods -n ${chosen_namespace} -l pod-template-hash=$POD_HASH_LABEL --show-labels | tail -n +2 | awk '{print $1}'`
    UNFILTERED_DEPLOY_NAME=$(kubectl get deploy -n ${chosen_namespace} | grep "\b${POD}\b")
}

first_pod_name() {
    chosen_namespace=$1
    microservice=$2
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

    if command -v fzfs &> /dev/null; then
        # Use fzf for namespace selection
        chosen_namespace=$(printf "%s\n" "${namespaces_array[@]}" | fzf --multi --cycle --reverse --height 10% --border --prompt "Select a namespace: " --preview "echo {}" --preview-window down:1:wrap)
        if [[ -z "$chosen_namespace" ]]; then
            echo "No namespace selected"
            exit 1
        fi
    else
        # Use select for namespace selection
        echo "Please select a namespace"
        select chosen_namespace in "${namespaces_array[@]}"; do
            if [[ -n "$chosen_namespace" ]]; then
                break
            else
                echo "invalid"
            fi
        done
    fi

    echo -e "You have selected the $chosen_namespace namespace"

    # Retrieve a list of deployments from Kubernetes and store them in an array
    microservices=$(kubectl get deployments -n $chosen_namespace -o=jsonpath='{.items[*].metadata.name}')
    IFS=' ' read -r -a microservices_array <<< "$microservices"
    if [[ ${#microservices_array[@]} -eq 0 ]]; then
        echo "No microservices found in the $chosen_namespace namespace"
        exit 1
    fi
    # Process each microservice to cut by "-"
    for i in "${!microservices_array[@]}"; do
        microservices_array[i]="${microservices_array[i]%%-*}"
    done

    if command -v fzfs &> /dev/null; then
        # Use fzf for microservice selection
        microservice=$(printf "%s\n" "${microservices_array[@]}" | fzf --multi --cycle --reverse --height 10% --border --prompt "Select a microservice: " --preview "echo {}" --preview-window down:1:wrap)
        if [[ -z "$microservice" ]]; then
            echo "No microservice selected. Exiting."
            exit 1
        fi
    else
        # Use select for microservice selection
        echo -e "\nPlease select a microservice"
        select microservice in "${microservices_array[@]}"; do
            if [[ -n "$microservice" ]]; then
                break
            else
                echo "invalid"
            fi
        done
    fi

    echo -e "You have selected the $microservice microservice\n"

    get_pods "$chosen_namespace" "$microservice"

    # After showing the pods, ask if the user wants another operation like logs or describe
    echo -e "Do you want to perform another operation? (e.g., logs, describe)"
    read -p "Enter the operation you want to perform: " operation
    echo 

    # Check the user's choice and execute the corresponding operation
    case $operation in
        logs)
            log_pod "$chosen_namespace" "$microservice"
            ;;
        describe)
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
