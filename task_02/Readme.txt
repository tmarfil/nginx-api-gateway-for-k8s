# Create a TLS cert and key for 'jobs.local' host.

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout jobs.local.key -out jobs.local.crt -config openssl.cnf -extensions req_ext

# Create a K8s TLS secret based on 'jobs.local' TLS cert and key.

kubectl create secret tls jobs-local-tls --key jobs.local.key --cert jobs.local.crt

# Create a VirutalServer Custom Resource Definition (CRD) to add TLS and proxy the API endpoints:
# /get-job # GET /get-job will return a random job title in json format from an ecclectic list of job titles
# /add-job # POST /add-job will accept an array of job titles to add to the ecclectic list of possible job titles

kubectl apply -f VirtualServer.yaml
