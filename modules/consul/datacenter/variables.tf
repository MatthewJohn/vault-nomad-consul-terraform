
variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "root_cert" {
  description = "Root certificate object"
  type = object({
    pki_mount_path = string
    common_name    = string
    organisation   = string
    ou             = string
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
