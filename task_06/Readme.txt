The rate-limiting key is the Authorization header. Every unique user will be 
rate-limited based on their unique Authorization header (JWT).

Copy your JWT to the k6-jobs.js script.
micro k6-jobs.js

From the jumphost, run a load test without rate-limiting:
k6 run k6-jobs.js --insecure-skip-tls-verify

Apply the rate-limiting policy:
k apply -f rate-limit-policy.yaml
k apply -f VirtualServer.yaml

From the jumphost, run a load test with rate-limiting:
k6 run k6-jobs.js --insecure-skip-tls-verify

When a client receives HTTP Error 429: "Too Many Requests" it should back off 
and retry.
