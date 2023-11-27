#!/bin/bash

# Run the commands
docker image ls
microk8s kubectl get svc -n kube-system
microk8s kubectl get pod -n kube-system

# Check if kube-dns service exists
if microk8s kubectl get svc -n kube-system | grep -q "kube-dns"; then
    # Check if all pods in kube-system are Running
    if [ $(microk8s kubectl get pod -n kube-system --no-headers | grep -v "Running" | wc -l) -eq 0 ]; then
        # Print 'clean' in green font
        printf "\e[32mclean\e[0m\n"
    else
        # Print 'dirty' in red font
        printf "\e[31mdirty\e[0m\n"
    fi
else
    # Print 'dirty' in red font
    printf "\e[31mdirty\e[0m\n"
fi
