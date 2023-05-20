
variable "vault_host" {
  description = "Node domain of main vault node"
  type        = string
}

variable "root_token" {
  description = "Root token for authenticating to vault"
  type        = string
}

variable "ca_cert_file" {
  description = "Path to vault CA file"
  type        = string
}
