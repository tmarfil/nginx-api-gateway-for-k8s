#!/bin/bash

# Define an array of resource types
resource_types=("daemonset" "deployment" "pod" "svc" "virtualserver" "policy" "appolicy" "secret")

# Function to display help message
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Run the script to check for Kubernetes resources in the 'default' namespace."
    echo ""
    echo "With no OPTION, the script checks if any of the following resources exist:"
    printf ' - %s\n' "${resource_types[@]}"
    echo ""
    echo "Options:"
    echo "  --start-over    Deletes all of the above resources from the 'default' namespace."
    echo "  --help          Display this help and exit."
    echo ""
    echo "The script ignores certain resources (e.g., service 'kubernetes')."
    echo "It displays 'clean' in green if no resources are found (except ignored ones),"
    echo "or 'dirty' in red if any resources are found."
}

# Check for flags
if [ "$1" == "--start-over" ]; then
    echo "Starting over: Deleting all resources..."
    for resource in "${resource_types[@]}"; do
        echo "Deleting all ${resource}s in the default namespace..."
        microk8s kubectl delete "$resource" --all --namespace default --grace-period=0 --force
    done
    echo "All resources deleted."
    exit 0
elif [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# Define an associative array of resource types and names to ignore
declare -A ignore_list
ignore_list["svc:kubernetes"]=1

# Flag to track if any non-ignored resource is found
any_non_ignored_resource_found=false

# Loop through each resource type and check for their existence in the 'default' namespace
for resource in "${resource_types[@]}"; do
    echo "Checking for ${resource} in the default namespace..."

    while read -r line; do
        resource_name=$(echo $line | awk '{print $1}')
        ignore_key="${resource}:${resource_name}"

        if [[ -z "${ignore_list[$ignore_key]}" ]]; then
            echo "$line"
            any_non_ignored_resource_found=true
        fi
    done < <(microk8s kubectl get "$resource" --namespace default --no-headers 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "No ${resource} resources found in the default namespace or ${resource} is not a valid resource type."
    fi

    echo ""  # Adding a newline for better readability
done

# Display final message
if [ "$any_non_ignored_resource_found" = false ]; then
    echo -e "\033[32mclean\033[0m"  # Green text
else
    echo -e "\033[31mdirty\033[0m"  # Red text
fi
