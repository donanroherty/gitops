#!/bin/bash

export $(grep -v '^#' .env | xargs)

export KUBE_CONFIG_PATH=~/.kube/config

# delete kind cluster if it exists, create a new one
echo "---- Creating a new kind cluster ----"
kind delete cluster --name $CLUSTER_NAME
kind create cluster --name $CLUSTER_NAME
echo ""

# echo "---- Deleting all non-protected namespaces and CRDs ----"
# kubectl delete ns --all --field-selector=metadata.name!=default,metadata.name!=kube-system
# kubectl get crd -o name | xargs kubectl delete
# echo ""

# echo "---- Create ArgoCD namespace ----"
# kubectl apply -f kubernetes/namespace.yaml
# echo ""

echo "---- Setup Vault ----"

helm repo add hashicorp https://helm.releases.hashicorp.com

helm install vault-secrets-operator hashicorp/vault-secrets-operator \
	--namespace vault-secrets-operator-system \
	--create-namespace

# todo change secret id
kubectl create secret generic vso-sp \
	--namespace default \
	--from-literal=clientID=$HCP_CLIENT_ID \
	--from-literal=clientSecret=$HCP_CLIENT_SECRET

kubectl create namespace argocd

kubectl create -f - <<EOF
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPAuth
metadata:
  name: default
  namespace: vault-secrets-operator-system
spec:
  organizationID: $HCP_ORG_ID
  projectID: $HCP_PROJECT_ID
  servicePrincipal:
    secretRef: vso-sp
EOF

kubectl create -f - <<EOF
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPVaultSecretsApp
metadata:
  name: argocd-auth
  namespace: argocd
spec:
  appName: $VAULT_ARGOCD_APP_NAME
  destination:
    create: true
    labels:
      hvs: "true"
    name: argocd-auth
  refreshAfter: 1h
EOF

kubectl create -f - <<EOF
apiVersion: secrets.hashicorp.com/v1beta1
kind: HCPVaultSecretsApp
metadata:
  name: ghcr-auth
  namespace: argocd
spec:
  appName: $VAULT_GHCR_APP_NAME
  destination:
    create: true
    labels:
      hvs: "true"
    name: ghcr-auth
  refreshAfter: 1h
EOF

kubectl apply -f kubernetes/secrets/argocd-auth-vault-secret.yaml
kubectl create -f kubernetes/secrets/ghcr-auth-vault-secret.yaml

# # install argocd
echo "---- Installing ArgoCD ----"
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl apply -f kubernetes/argocd
echo ""

echo "---- Waiting for ArgoCD to be ready ----"
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
echo ""

echo "---- Logging into ArgoCD ----"
argocd login localhost:8080 --grpc-web --insecure --username ${ARGO_USERNAME} --password '${ARGO_PASSWORD}'
