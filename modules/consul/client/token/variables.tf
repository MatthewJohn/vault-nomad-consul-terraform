variable "docker_host" {
  description = "Docker host to connect to"
  type = object({
    hostname = string
  })
}

variable "datacenter" {
  description = "Consul datacenter"
  type = object({
    name                                     = string
    common_name                              = string
    client_ca_role_name                      = string
    pki_mount_path                           = string
    static_mount_path                        = string
    consul_engine_mount_path                 = string
    approle_mount_path                       = string
    pki_connect_mount_path                   = string
    client_consul_template_approle_role_name = string
    gossip_encryption = object({
      mount = string
      name  = string
    })
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    consul_static_mount_path = string
  })
}