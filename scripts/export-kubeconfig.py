import yaml
import base64
import subprocess
import os

from dotenv import load_dotenv
from pathlib import Path

dotenv_path = Path('.env')
load_dotenv(dotenv_path=dotenv_path)


context_name = os.environ['CLUSTER_NAME']
tunnel_address = os.environ['TUNNEL_ADDRESS']
cluster_port = os.environ['CLUSTER_PORT']
output_file = "minimal-kubeconfig.yaml"

# Get the raw kubeconfig data
raw_kubeconfig = subprocess.check_output("kubectl config view --raw", shell=True).decode("utf-8")

# Load the raw kubeconfig YAML
kubeconfig = yaml.safe_load(raw_kubeconfig)

# Extract the desired context
context = next((c for c in kubeconfig["contexts"] if c["name"] == context_name), None)

# Extract the associated cluster and user
cluster_name = context["context"]["cluster"]
user_name = context["context"]["user"]

cluster = next((c for c in kubeconfig["clusters"] if c["name"] == cluster_name), None)
user = next((u for u in kubeconfig["users"] if u["name"] == user_name), None)

# Update the cluster server address
cluster["cluster"]["server"] = f"https://{tunnel_address}:{cluster_port}"

# Create the minimal kubeconfig
minimal_kubeconfig = {
    "apiVersion": "v1",
    "kind": "Config",
    "current-context": context_name,
    "contexts": [context],
    "clusters": [cluster],
    "users": [user]
}

# convert to base64
minimal_kubeconfig = base64.b64encode(yaml.dump(minimal_kubeconfig).encode("utf-8")).decode("utf-8")
print(minimal_kubeconfig)

print(f"Minimal kubeconfig saved to {output_file}")


# Generate sealed secret for ArgoCD credentials
with open("kubernetes/sealed-secrets/argocd-secrets.yaml", "r") as f:
    argocd_secrets = yaml.safe_load(f)

sealed_secret = {
    "apiVersion": "bitnami.com/v1alpha1",
    "kind": "SealedSecret",
    "metadata": {
        "name": "argocd-secrets",
        "namespace": "argocd",
    },
    "spec": {
        "encryptedData": {
            "admin.password": base64.b64encode(argocd_secrets["stringData"]["admin.password"].encode("utf-8")).decode("utf-8"),
            "admin.username": base64.b64encode(argocd_secrets["stringData"]["admin.username"].encode("utf-8")).decode("utf-8"),
        },
    },
}

with open("kubernetes/sealed-secrets/argocd-sealed-secrets.yaml", "w") as f:
    yaml.dump(sealed_secret, f)