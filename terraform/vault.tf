/*
data "local_file" "ghcr_auth_secret" {
  filename = "${path.module}/../manifests/vault-secrets/ghcr-auth-vault-secret.yaml"
}

resource "vault_generic_secret" "ghcr_auth" {
  path      = "secret/ghcr-auth"
  data_json = jsonencode({
    ".dockerconfigjson" = data.local_file.ghcr_auth_secret.content
  })
}
*/

resource "vault_generic_secret" "argocd_auth" {
  path = "secret/argocd-auth"
  data_json = jsonencode({
    "admin.username" = var.argocd_username
    "admin.password" = var.argocd_password
  })
}

data "vault_generic_secret" "ghcr_auth" {
  path = "secret/ghcr-auth"
}

data "vault_generic_secret" "argocd_auth" {
  path = "secret/argocd-auth"
}
