variable "datacenter" {
  description = "Consul datacenter"
  type = object({
    name                 = string
    common_name          = string
    role_name            = string
    pki_mount_path       = string
    root_cert_public_key = string
    address              = string
  })
}

variable "bootstrap" {
  description = "Value of consul bootstrap"
  type = object({
    token = string
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

variable "consul_servers" {
  description = "List of consul servers"
  type = list(object({
    hostname = string
  }))
  default = []
}

locals {
  consul_server_map = {
    for server in var.consul_servers :
    server.hostname => server
  }
}
