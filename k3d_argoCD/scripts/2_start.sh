#!/bin/bash

##Let’s setup our cluster with 2 worker nodes (–agents in k3d command line) and expose the HTTP load balancer on the host on port 8080 (so that we can interact with our application)
##--api-port - by default, no API-Port is exposed. It’s used to have k3s‘s API-Server listening on port 6443
echo -e "\e[32m\nCreating cluster:\e[0m"
k3d cluster create my-cluster --api-port 6443 -p 8080:80@loadbalancer --agents 2 --wait

echo -e "\e[32m\nCreating namespaces:\e[0m"
kubectl create namespace argocd
kubectl create namespace dev


##  apply this script from the ArgoCD team, which will take care of the rest.
echo -e "\e[32m\nApplying stable manifests for ArgoCD:\e[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
## Use the watch command to ensure the pods are running and ready.
echo -e "\e[32m\nAwaiting pods are running and ready...\e[0m"
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=120s

echo -e "\e[32m\nApplying new password to ArgoCD:\e[0m"
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$12$Iy3op7PDM/PWJ/8kRyn0ROWImQa5TSzQmL.8GTj0dNpEagZbQsnPG",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

## We want our work inside ArgoCD to be hosted in a dedicated project named iot-project. 
## Allow only in-cluster deployments in the dev namespace and only for the acaren github repositories.
echo -e "\e[32m\nApplying config 'project.yaml':\e[0m"
kubectl apply -f ../confs/project.yaml -n argocd

## Next, we will create an ArgoCD Application which will synchronize our Kubernetes manifests
## hosted in the app folder on our github repository (https://github.com/jesuisstan/todo_app_manifest)
## with the associated resources inside the dev namespace on our local cluster:
echo -e "\e[32m\nApplying config 'application.yaml':\e[0m"
kubectl apply -f ../confs/application.yaml -n argocd

echo -e "\e[32m\nAwaiting pods are running and ready...\e[0m"
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=42s


echo -e "
\e[33m\nARGO CD IS DEPLOYED!\nFOLLOW THE INSTRUCTION TO WORK WITH IT:\n
1) to access ArgoCD web dashboard run cmd:\n
\e[35m./3_openArdoCD.sh\e[33m

2) to access TodoReactApp run cmd:\n
\e[35m./4_openTodoApp.sh\e[0m
"
