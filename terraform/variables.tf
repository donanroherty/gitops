variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
}

variable "vault_token" {
  description = "The token used to authenticate with Vault"
  type        = string
}

variable "argocd_server_addr" {
  description = "The address of the ArgoCD server"
  type        = string
}

variable "argocd_auth_token" {
  description = "The authentication token for ArgoCD"
  type        = string
}

variable "argocd_username" {
  description = "The username for ArgoCD authentication"
  type        = string
}

variable "argocd_password" {
  description = "The password for ArgoCD authentication"
  type        = string
}
