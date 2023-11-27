#!/bin/bash

NAMESPACE="nginx-ingress"
resource_types=("pods" "svc" "deployments" "daemonsets" "statefulsets" "replicasets" "ingresses")

for resource in "${resource_types[@]}"; do
    echo "Listing ${resource} in namespace ${NAMESPACE}:"
    microk8s kubectl get "$resource" --namespace "$NAMESPACE"
    echo ""
done
