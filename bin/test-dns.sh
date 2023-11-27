#!/bin/bash

# Default FQDN
DEFAULT_FQDN="www.f5.com"

# Help message
function show_help() {
    echo "Usage: $0 [FQDN]"
    echo "       $0 --help"
    echo
    echo "This script applies a BusyBox Kubernetes manifest and then"
    echo "executes wget to fetch a website within the BusyBox pod."
    echo
    echo "Arguments:"
    echo "  FQDN    Fully Qualified Domain Name to fetch. Default is $DEFAULT_FQDN."
    echo "          Example: $0 www.example.com"
    echo
    echo "Options:"
    echo "  --help  Show this help message."
}

# Check for help flag
if [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# Set FQDN (use default if no argument is provided)
FQDN=${1:-$DEFAULT_FQDN}

# Kubernetes BusyBox manifest as a here-document
MANIFEST=$(cat <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sleep", "3600"]
      resources: {}
      stdin: true
      tty: true
EOF
)

# Apply the Kubernetes manifest
echo "$MANIFEST" | microk8s kubectl apply -f -

# Ensure the pod is ready
echo "Waiting for BusyBox pod to be ready..."
microk8s kubectl wait --for=condition=Ready pod/busybox --timeout=60s

# Execute wget inside the BusyBox pod
microk8s kubectl exec -it busybox -- wget --no-check-certificate $FQDN

# Clean up: Delete the pod
echo "Cleaning up: Deleting the BusyBox pod..."
microk8s kubectl delete pod busybox
