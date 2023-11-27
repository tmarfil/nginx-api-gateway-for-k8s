# This task failed ocassionally during testing because the nginx ingress pod (and all other pods on the microk8s cluster) were not able to resolve DNS.
#
# To test if this is the issue run the 'test-dns.sh' script.
# test-dns.sh --help for usage info.
# 
# Also check the kube-system logs:
# microk8s kubectl logs -n kube-system -l k8s-app=kube-dns
# [INFO] 127.0.0.1:58129 - 21340 "HINFO IN 8060823575723639096.697009577592649424. udp 56 false 512" - - 0 2.001173139s
# [ERROR] plugin/errors: 2 8060823575723639096.697009577592649424. HINFO: read udp 10.1.35.156:56417->8.8.8.8:53: i/o timeout

test-dns.sh
kubectl apply -f jobs-openapi-spec-appolicy.yaml
kubectl apply -f app-protect-policy.yaml
kubectl apply -f VirtualServer.yaml
