
variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "root_cert" {
  description = "Root certificate object"
  type = object({
    pki_mount_path   = string
    common_name      = string
    organisation     = string
    ou               = string
    public_key       = string
    issuer           = string
    domain_name      = string
    consul_subdomain = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file = string
    address      = string
    token        = string
  })
}

variable "agent_ips" {
  description = "List of all agent IP addresses"
  type        = list(string)
  default     = []
}
