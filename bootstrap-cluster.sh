#!/bin/bash

source config/.env

echo "---- Creating cluster ----"
kind delete cluster --name ${CLUSTER_NAME}
kind create cluster --name ${CLUSTER_NAME}
echo ""

# echo "---- Deleting all non-protected namespaces and CRDs ----"
# kubectl delete ns --all --field-selector=metadata.name!=default,metadata.name!=kube-system
# kubectl get crd -o name | xargs kubectl delete
# echo ""

export KUBE_CONFIG_PATH=~/.kube/config

echo "---- Provisioning cluster using Terraform ----"
cd terraform
terraform init
terraform apply -auto-approve

echo "---- Bootstrapping complete ----"
