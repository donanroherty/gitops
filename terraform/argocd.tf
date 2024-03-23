resource "argocd_application" "service_hub_root" {
  metadata {
    name      = "service-hub-root"
    namespace = "argocd"
  }
  spec {
    project = "service-hub-project"
    source {
      repo_url        = "https://github.com/donanroherty/gitops.git"
      path            = "manifests/argocd-config"
      target_revision = "HEAD"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }
    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
    }
  }
}

resource "argocd_project" "service_hub_project" {
  metadata {
    name      = "service-hub-project"
    namespace = "argocd"
  }
  spec {
    description  = "Project for Next.js application and related services"
    source_repos = ["*"]
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }
  }
}

resource "argocd_repository" "ghcr_auth" {
  type            = "git"
  repo            = "https://github.com/donanroherty/gitops.git"
  username        = data.vault_generic_secret.ghcr_auth.data["username"]
  password        = data.vault_generic_secret.ghcr_auth.data["password"]
  ssh_private_key = null
  insecure        = false
  enable_lfs      = false
}

resource "argocd_repository_credentials" "argocd_auth" {
  url = "https://github.com/donanroherty/gitops.git"
  username = data.vault_generic_secret.argocd_auth.data["username"]
  password = data.vault_generic_secret.argocd_auth.data["password"]
}
