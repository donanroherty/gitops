# Setup

## Setup Argo CD

```bash
# Create the argocd namespace and install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Argo Rollouts
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Install Kustomize
brew install kustomize
kubectl apply -k kubernetes/overlays/blue
kubectl apply -k kubernetes/overlays/green

kubectl create secret docker-registry ghcr-auth --docker-server=ghcr.io --docker-username=donanroherty --docker-password=<your-github-username> --docker-email=donanroherty@gmail.com

# Add the argocd cluster
argocd cluster add docker-desktop

# launch the argocd server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# get the initial password
argocd admin initial-password -n argocd

# login
argocd login localhost:8080

# update the password
argocd account update-password
```


## Setup project

```bash
# Create the service-hub namespace and install the service-hub
kubectl apply -f kubernetes/namespace.yaml

kubectl -n service-hub-ns apply -k kubernetes/base/

# Create the ArgoCD project
argocd proj create -f .argocd/project.yaml

# Create the blue and green applications in ArgoCD
argocd app create -f .argocd/site-app-blue.yaml

# Create the blue and green applications in ArgoCD
kubectl apply -k kubernetes/overlays/blue
```

### Manage contexts

```bash
# show current context
kubectl config current-context

# show all contexts
kubectl config get-contexts

# switch context
kubectl config use-context <your-context-name>
```