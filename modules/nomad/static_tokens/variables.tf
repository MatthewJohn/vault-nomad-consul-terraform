variable "root_cert" {
  description = "Root certificate object"
  type = object({
    public_key = string
  })
}

variable "region" {
  description = "Nomad region"
  type = object({
    name    = string
    address = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    token                    = string
    consul_static_mount_path = string
  })
}

variable "bootstrap" {
  description = "Nomad bootstrap object"
  type = object({
    token = string
  })
}
