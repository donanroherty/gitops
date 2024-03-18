#!/bin/bash

export $(grep -v '^#' .env | xargs)

export KUBE_CONFIG_PATH=~/.kube/config

# kind delete cluster -n gitops
# kind create cluster -n gitops

# delete all non-protected namespaces
kubectl delete ns --all --field-selector=metadata.name!=default,metadata.name!=kube-public,metadata.name!=kube-system
kubectl get crd -o name | xargs kubectl delete

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -k kubernetes/sealed-secrets
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f kubernetes/argocd

# ./init-terraform.sh
