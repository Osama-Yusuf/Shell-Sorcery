#!/bin/bash

show_help() {
    echo "Usage: $0"
    echo "Usage: $0 <namespace> <microservice>"
    echo "Usage: $0 <namespace> <microservice> <get || logs || describe || exec || delete || envs>"
    echo
    echo -e "Example: $0 dev books\nThis will list all book pods in the dev namespace\n"
    echo -e "Example: $0 dev books logs\nThis will log the first book pod in the dev namespace\n"
    echo -e "Example: $0 dev books logs each\nThis will log each book pod in the dev namespace in a loop\n"
    echo -e "Example: $0 dev books describe\nThis will describe the first book pod in the dev namespace\n"
    echo -e "Example: $0 dev books exec\nThis will exec into the first book pod in the dev namespace\n"
    echo -e "Example: $0 dev books delete\nThis will delete the book pods in the dev namespace one by one, only when the user confirms with yes\n"
    echo -e "Example: $0 dev books delete --auto-approve\nThis will delete the book pods in the dev namespace one by one, without user confirmation\n"
    echo -e "Example: $0 dev books envs\nThis will show environment variables of the first book pod in the dev namespace\n"
    echo -e "Example: $0 dev books envs VAR_NAME\nThis will show environment variables containing VAR_NAME of the first book pod in the dev namespace"
}

# check if the above command succeeded if not exit
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "$1\n"
        show_help
        exit 1
    fi
}

pod_names() {
    chosen_namespace=$1
    POD=$2
    DEPLOY_NAME=$(kubectl get deploy -n ${chosen_namespace} | grep "\b${POD}\b" | awk '{print $1}')
    if [ -z "$DEPLOY_NAME" ]; then
        echo "No deployment found for $POD"
        exit 1
    fi
    RS_NAME=$(kubectl describe deployment $DEPLOY_NAME -n ${chosen_namespace} | grep "^NewReplicaSet" | awk '{print $2}')
    POD_HASH_LABEL=$(kubectl get rs $RS_NAME -n ${chosen_namespace} -o jsonpath="{.metadata.labels.pod-template-hash}")
    POD_NAMES=$(kubectl get pods -n ${chosen_namespace} -l pod-template-hash=$POD_HASH_LABEL --show-labels | tail -n +2 | awk '{print $1}')
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

log_all_pods() {
    chosen_namespace=$1
    microservice=$2
    pod_names "$chosen_namespace" "$microservice"
    while true; do
        for pod in $POD_NAMES; do
            echo "Logs for pod $pod:"
            kubectl logs -n $chosen_namespace $pod
            sleep 4
            clear
        done
    done
}

describe_pod() {
    first_pod_name "$chosen_namespace" "$microservice"
    kubectl describe pod -n $chosen_namespace $first_pod_name
}

exec_pod() {
    first_pod_name "$chosen_namespace" "$microservice"
    kubectl exec -it -n $chosen_namespace $first_pod_name -- sh
}

delete_pod() {
    chosen_namespace=$1
    microservice=$2
    auto_approve=$3
    pod_names "$chosen_namespace" "$microservice"

    echo "The following pods will be deleted one by one in the $chosen_namespace namespace:"
    echo "$POD_NAMES"
    echo

    if [ "$auto_approve" != "--auto-approve" ]; then
        read -p "Are you sure you want to delete these pods? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            echo "Aborting deletion."
            exit 1
        fi
    fi

    for pod in $POD_NAMES; do
        echo "Deleting pod $pod..."
        kubectl delete pod -n $chosen_namespace $pod >/dev/null
        echo "Pod $pod has been deleted."
    done
}

envs_pod() {
    first_pod_name "$chosen_namespace" "$microservice"
    if [ -z "$3" ]; then
        kubectl exec -n $chosen_namespace $first_pod_name -- printenv
    else
        kubectl exec -n $chosen_namespace $first_pod_name -- printenv | grep -i "$3"
    fi
}

no_args_passed() {
    # Retrieve a list of namespaces from Kubernetes and store them in an array
    namespaces=$(kubectl get namespace -o=jsonpath='{.items[*].metadata.name}')
    IFS=' ' read -r -a namespaces_array <<< "$namespaces"

    if command -v fzf &> /dev/null; then
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

    if command -v fzf &> /dev/null; then
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
                false || check_success "invalid input $REPLY"
            fi
        done
    fi

    echo -e "You have selected the $microservice microservice\n"

    get_pods "$chosen_namespace" "$microservice"

    # After showing the pods, ask if the user wants another operation like logs, describe, exec, delete, or envs
    echo -e "Do you want to perform another operation? (e.g., logs, describe, exec, delete, envs)"
    read -p "Enter the operation you want to perform: " operation
    echo 

    # Check the user's choice and execute the corresponding operation
    case $operation in
        logs)
            read -p "Do you want to log each pod in a loop? (yes/no): " each_choice
            if [[ "$each_choice" == "yes" ]]; then
                log_all_pods "$chosen_namespace" "$microservice"
            else
                log_pod "$chosen_namespace" "$microservice"
            fi
            ;;
        describe)
            describe_pod "$chosen_namespace" "$microservice"
            ;;
        exec)
            exec_pod "$chosen_namespace" "$microservice"
            ;;
        delete)
            delete_pod "$chosen_namespace" "$microservice"
            ;;
        envs)
            read -p "Enter the variable name to filter by (optional): " var_name
            envs_pod "$chosen_namespace" "$microservice" "$var_name"
            ;;
        *)
            false || check_success "Invalid operation. Exiting."
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
        case $3 in
            get)
                get_pods "$chosen_namespace" "$microservice"
                ;;
            logs)
                log_pod "$chosen_namespace" "$microservice"
                ;;
            describe)
                describe_pod "$chosen_namespace" "$microservice"
                ;;
            exec)
                exec_pod "$chosen_namespace" "$microservice"
                ;;
            delete)
                delete_pod "$chosen_namespace" "$microservice"
                ;;
            envs)
                envs_pod "$chosen_namespace" "$microservice"
                ;;
            *)
                false || check_success "Invalid operation. Exiting."
                ;;
        esac
    elif [ "$#" -eq 4 ] && [ "$3" == "logs" ]; then
        chosen_namespace=$1
        microservice=$2
        log_all_pods "$chosen_namespace" "$microservice"
    elif [ "$#" -eq 4 ] && [ "$3" == "envs" ]; then
        chosen_namespace=$1
        microservice=$2
        envs_pod "$chosen_namespace" "$microservice" "$4"
    elif [ "$#" -eq 4 ] && [ "$3" == "delete" ]; then
        chosen_namespace=$1
        microservice=$2
        delete_pod "$chosen_namespace" "$microservice" "$4"
    else
        check_success "Invalid number of arguments. Exiting."
    fi
}

main "$@"
