kubectl apply -f VirtualServer.yaml

All features working together on a single endpoint:
- /add-job api endpoints are protected by an App Protect policy that enforces 
  the api schema based on an openapi file
- /add-job api endpoint is authorizing users based on the JWT in the
  authorization header
- /add-job api endpoint is rate-limiting users using the JWT as a key
