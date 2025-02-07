#!/bin/bash

# Get JWT from secret and decode base64
JWT=$(microk8s kubectl get secret license-token -n nginx-ingress -o jsonpath='{.data.license\.jwt}' | base64 -d)

# Extract and decode the payload (second part of JWT between dots)
PAYLOAD=$(echo $JWT | cut -d'.' -f2 | base64 -d 2>/dev/null)

# Pretty print the JSON
echo "JWT Payload:"
echo $PAYLOAD | python3 -m json.tool
echo

# Extract timestamps
IAT=$(echo $PAYLOAD | python3 -c "import sys, json; print(json.load(sys.stdin)['iat'])")
SAT=$(echo $PAYLOAD | python3 -c "import sys, json; print(json.load(sys.stdin)['f5_sat'])")
CURRENT=$(date +%s)

# Convert and display dates
echo "Issue date: $(date -d @$IAT)"
echo "End date:   $(date -d @$SAT)"
echo

# Check if license is expired
if [ $CURRENT -gt $SAT ]; then
    echo "[!] LICENSE HAS EXPIRED"
else
    echo "[+] License is valid"
    # Calculate days remaining
    DAYS_REMAINING=$(( ($SAT - $CURRENT) / 86400 ))
    echo "Days remaining: $DAYS_REMAINING"
fi
