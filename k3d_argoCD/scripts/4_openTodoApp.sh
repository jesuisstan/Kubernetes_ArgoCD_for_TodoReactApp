#!/bin/bash

# Run the kubectl port-forward command in the background
kubectl port-forward svc/todo-app-service -n dev 3000:3000 &

# Wait for a moment to allow the port-forwarding to start
sleep 5

# Open the browser with the specified URL
xdg-open http://localhost:3000

