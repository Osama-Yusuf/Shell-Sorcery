#!/bin/bash

namespaces=$(kubectl get namespace -o=jsonpath='{.items[*].metadata.name}')
IFS=' ' read -r -a namespaces_array <<< "$namespaces"

echo "\nPlease select a namespace "

select chosen_namespace in "${namespaces_array[@]}"; do
    if [[ -n "$chosen_namespace" ]]; then
        echo -e "\nyou have selected ns: $chosen_namespace\n"
        break
    else
        echo "invalid"
    fi
done

microservices=$(kubectl get deploy -n $chosen_namespace -o=jsonpath='{.items[*].metadata.name}')
IFS=' ' read -r -a microservices_array <<< "$microservices"

for i in "${!microservices_array[@]}"; do
    microservices_array[i]="${microservices_array[i]%%-*}"
done

echo -e "\nPlease select a microservice "

select microservice in "${microservices_array[@]}"; do
    if [[ -n "$microservice" ]]; then
        echo -e "\nYou have selected: $microservice\n"
        break
    else
        echo "invalid"
    fi
done

counter=1
microservice_pods=$(kubectl get pods -n $chosen_namespace | grep $microservice | awk '{print $1}')

for microservice_pod in $microservice_pods
do
    microservice_id=$(echo $microservice_pod | cut -d "-" -f5)
    echo "$microservice Pod No.$counter with ID of $microservice_id validation output:"
    validation_output=$(kubectl describe pod $microservice_pod -n $chosen_namespace | grep -i image | grep -vi "image id"| grep release: | cut -d ":" -f4)
    echo -e "$validation_output\n"
    ((counter++))
done
