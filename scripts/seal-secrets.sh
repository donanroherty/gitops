#!/bin/bash

# Load .env variables
export $(egrep -v '^#' config/.env | xargs)

# Base64 encode your secrets
export ARGOCD_USERNAME=$(echo -n "${ARGOCD_USERNAME}" | base64)
export ARGOCD_PASSWORD=$(echo -n "${ARGOCD_PASSWORD}" | base64)
GHCR_ENCODED_AUTH=$(echo -n "${GHCR_USERNAME}:${GHCR_PASSWORD}" | base64)
export GHCR_AUTH=$(echo -n "{\"auths\":{\"ghcr.io\":{\"auth\":\"${GHCR_ENCODED_AUTH}\"}}}" | base64)

SEALED_SECRETS_CERT=config/sealed-secrets-pub.pem

# Use envsubst to substitute the environment variables into the template and pipe to kubeseal
envsubst <manifests/sealed-secrets/secrets.yaml.template |
	kubeseal --format yaml --cert ${SEALED_SECRETS_CERT} >manifests/sealed-secrets/sealed-secrets.yaml
