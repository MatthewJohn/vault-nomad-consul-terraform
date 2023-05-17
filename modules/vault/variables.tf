
variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

variable "vault_version" {
  description = "Vault version"
  type = string
  default = "1.13.2"
}
