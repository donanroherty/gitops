terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "argocd" {
  server_addr = var.argocd_server_addr
  auth_token  = var.argocd_auth_token
  insecure    = true
}

resource "kubernetes_secret" "sealed_secrets_key" {
  metadata {
    name      = "sealed-secrets-key"
    namespace = "kube-system"
  }

  data = {
    "sealed-secrets-pub.pem" = file("../config/sealed-secrets-pub.pem")
  }
}

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "kube-system"

  set {
    name  = "secretName"
    value = kubernetes_secret.sealed_secrets_key.metadata[0].name
  }
}

