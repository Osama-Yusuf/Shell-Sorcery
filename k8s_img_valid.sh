#!/bin/bash

# Retrieve a list of namespaces from Kubernetes and store them in an array
namespaces=$(kubectl get namespace -o=jsonpath='{.items[*].metadata.name}')
IFS=' ' read -r -a namespaces_array <<< "$namespaces"

# Prompt the user to select a namespace from the list
echo "Please select a namespace "

# Provide a selection mechanism for the namespace array
select chosen_namespace in "${namespaces_array[@]}"; do
    # Check if a namespace was selected
    if [[ -n "$chosen_namespace" ]]; then
        echo -e "\nYou have selected $chosen_namespace namespace\n"
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

# Initialize a counter for pods
counter=1
# Retrieve a list of pods from the selected namespace that match the microservice name
microservice_pods=$(kubectl get pods -n $chosen_namespace | grep $microservice | awk '{print $1}')

# Loop through each pod associated with the microservice
for microservice_pod in $microservice_pods
do
    # Extract the microservice ID from the pod name
    microservice_id=$(echo $microservice_pod | cut -d "-" -f5)
    echo "Microservice Pod No.$counter with ID of $microservice_id validation output:"
    # Describe the pod and filter for image id and release information, store in variable
    validation_output=$(kubectl describe pod $microservice_pod -n $chosen_namespace | grep -i image | grep -vi "image id" | grep release: | cut -d " " -f4)
    # Print the validation output
    echo -e "$validation_output\n"
    ((counter++)) # Increment the counter
done
