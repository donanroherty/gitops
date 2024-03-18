# Setup

# MacOS CLIs
```sh
brew install kind
brew install kubectl
brew install kustomize
brew install terraform
brew install argocd
brew install helm
brew install kubeseal
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Setup Argo CD

```sh
export KUBE_CONFIG_PATH=~/.kube/config
kind delete cluster -n gitops
kind create cluster -n gitops

chmod +x terraform/setup
terraform/setup

cd terraform
terraform init
terraform apply -auto-approve

kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd     # wait for the argocd server to be available

kubectl port-forward -n argocd svc/argocd-server 8080:443             # launch the argocd server

helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets -n kube-system

argocd login localhost:8080 --username=admin --password='<password>'

kubectl apply -f kubernetes/argocd/                                   # create the argocd namespace and install argocd
argocd app sync service-hub-root                                      # sync the application
argocd app get service-hub-root                                       # check the status of the application


kubectl port-forward -n argocd svc/service-hub-app 3000:80            # forward the service-hub-app to localhost:3000


kubectl create secret docker-registry ghcr-auth --docker-server=ghcr.io --docker-username=donanroherty --docker-password=<your-github-username> --docker-email=donanroherty@gmail.com

argocd cluster add kind-gitops

kubectl port-forward svc/argocd-server -n argocd 8080:443   # launch the argocd server
```

## Secret management
```sh

kubeseal --format yaml --controller-name=sealed-secrets-controller < kubernetes/secrets/ghcr-auth-secret.yaml > kubernetes/secrets/ghcr-auth-sealed-secret.yaml
```

```sh
cat ~/.kube/config | base64   # create a base64 verion of the kubeconfig and add it to secrets.KUBECONFIG_BASE64 in github
```

### Common admin commands

```sh
kubectl config current-context                      # show current context
kubectl config get-contexts                         # list all contexts# show all contexts
kubectl config use-context <your-context-name>      # switch context
```