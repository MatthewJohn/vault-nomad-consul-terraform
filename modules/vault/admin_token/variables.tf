variable "admin_policy_name" {
  description = "Name of policy to create for admins"
  type        = string
  default     = "vault-admin"
}

variable "admin_role_name" {
  description = "Name of admin role to create"
  type        = string
  default     = "vault-admin"
}

variable "root_token" {
  description = "Root token to authenticate to cluster"
  type        = string
}

variable "vault_cluster" {
  description = "Path to root CA file"
  type        = object({
      ca_cert_file = string
      address      = string
  })
}
