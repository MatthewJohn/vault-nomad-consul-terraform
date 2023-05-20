
variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

variable "vault_subdomain" {
  description = "Subdomain of primary domain for vault"
  type        = string
  default     = "vault"
}

variable "ip_addresses" {
  description = "List of all vault IP Addresses"
  type        = list(string)
  default     = []
}

variable "ca_cert_file" {
  description = "Path to root certificate"
  type        = string
}

variable "admin_policy_name" {
  description = "Name of policy to create for admins"
  type        = string
  default     = "vault-admin"
}

variable "terraform_policy_name" {
  description = "Name of policy to create for terraform"
  type        = string
  default     = "terraform"
}

variable "root_token" {
  description = "Root token to authenticate to cluster"
  type        = string
}
