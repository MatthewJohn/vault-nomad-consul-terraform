
variable "consul_domain" {
  description = "Consul domain"
}

variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file = string
    address      = string
    token        = string
  })
}
