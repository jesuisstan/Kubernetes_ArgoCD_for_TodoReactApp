#!/bin/bash

echo -e "\e[33m\nTo enter ARGO CD account use the following:\n
\e[35mUsername: admin
Password: 0000\e[0m
"

# Run the kubectl port-forward command in the background
kubectl port-forward svc/argocd-server -n argocd 9999:443 &

# Wait for a moment to allow the port-forwarding to start
sleep 5

# Open the browser with the specified URL
xdg-open http://localhost:9999

