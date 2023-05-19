
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
