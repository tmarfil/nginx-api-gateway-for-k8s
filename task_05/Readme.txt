create-signed-jwt.sh
kubectl create secret generic jwk-secret --from-file=jwk=/var/tmp/jwk/jwk.json --type=nginx.org/jwk
kubectl get secret jwk-secret -o yaml
kubectl apply -f jwt-policy.yaml
kubectl apply -f VirtualServer.yaml
