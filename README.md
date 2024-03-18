# Setup

- [Docker](https://www.docker.com/get-started)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Terraform](https://www.terraform.io/downloads.html)
- [Argo CD CLI](https://argoproj.github.io/argo-cd/cli_installation/)

## Setup Argo CD

```sh
brew install kind
brew install kubectl
brew install kustomize
brew install terraform
brew install argocd

kind create cluster

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

kubectl apply -k kubernetes/overlays/blue

kubectl create secret docker-registry ghcr-auth --docker-server=ghcr.io --docker-username=donanroherty --docker-password=<your-github-username> --docker-email=donanroherty@gmail.com

argocd cluster add kind-gitops

kubectl port-forward svc/argocd-server -n argocd 8080:443   # launch the argocd server

argocd admin initial-password -n argocd                     # get the initial password
argocd login localhost:8080                                 # login to the argocd server
argocd account update-password                              # update the password
```

## Secret management
```sh
brew install helm
brew install kubeseal
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets -n kube-system

kubeseal --format yaml --controller-name=sealed-secrets < kubernetes/ghcr-auth-secret.yaml > ghcr-auth-sealed-secret.yaml
```

```sh
cat ~/.kube/config | base64   # create a base64 verion of the kubeconfig and add it to secrets.KUBECONFIG_BASE64 in github
```


## Setup project

```sh
kubectl apply -f kubernetes/namespace.yaml          # Create the service-hub namespace and install the service-hub
kubectl -n service-hub-ns apply -k kubernetes/base  # Create the service-hub application in the service-hub namespace

argocd proj create -f .argocd/project.yaml          # Create the service-hub project in ArgoCD
argocd app create -f .argocd/site-app-blue.yaml     # Create the blue and green applications in ArgoCD
kubectl apply -k kubernetes/overlays/blue           # Deploy the blue application
```

### Manage contexts

```sh
kubectl config current-context                      # show current context
kubectl config get-contexts                         # list all contexts# show all contexts
kubectl config use-context <your-context-name>      # switch context
```