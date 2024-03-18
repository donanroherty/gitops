#!/bin/bash

export $(grep -v '^#' .env | xargs)

cd terraform

# Initialize and apply Terraform configuration
terraform init
terraform apply -auto-approve

cd ..

kubectl apply -k kubernetes/sealed-secrets

# Wait for Argo CD to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Apply the app-of-apps manifest
kubectl apply -f kubernetes/argocd/

argocd login $TUNNEL_ADDRESS:$CLUSTER_PORT --username $ARGO_USERNAME --password '$ARGO_PASSWORD' --insecure

# Sync the app-of-apps
argocd app sync service-hub-root


# kubectl port-forward -n argocd svc/argocd-server 8080:443