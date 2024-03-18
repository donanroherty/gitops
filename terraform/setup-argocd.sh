#!/bin/bash

# Initialize and apply Terraform configuration
terraform init
terraform apply -auto-approve

# Wait for Argo CD to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Apply the app-of-apps manifest
kubectl apply -f kubernetes/argocd/app-of-apps.yaml

# Sync the app-of-apps
argocd app sync service-hub-root