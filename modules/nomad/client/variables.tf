variable "root_cert" {
  description = "Nomad root certificate authority"
  type = object({
    pki_mount_path = string
    common_name    = string
    public_key     = string
  })
}

variable "region" {
  description = "Nomad region"
  type = object({
    name               = string
    common_name        = string
    approle_mount_path = string
    server_dns         = string
    pki_mount_path     = string
  })
}

variable "datacenter" {
  description = "Nomad datacenter"
  type = object({
    name                                     = string
    common_name                              = string
    pki_mount_path                           = string
    client_consul_template_approle_role_name = string
    client_dns                               = string
    client_pki_role_name                     = string
    vault_jwt_path                           = string
    consul_auth_method                       = string
    harbor_account = object({
      secret_mount = string
      secret_name  = string
    })
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
    ca_cert                  = string
  })
}

variable "consul_root_cert" {
  description = "Consul root certificate authority"
  type = object({
    pki_mount_path         = string
    common_name            = string
    organisation           = string
    ou                     = string
    pki_connect_mount_path = string
    public_key             = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                                     = string
    common_name                              = string
    client_ca_role_name                      = string
    pki_mount_path                           = string
    client_consul_template_approle_role_name = string
    static_mount_path                        = string
    consul_engine_mount_path                 = string
    approle_mount_path                       = string
    pki_connect_mount_path                   = string
    ca_chain                                 = string
    root_cert_public_key                     = string
    address                                  = string
    gossip_encryption = object({
      mount = string
      name  = string
    })
  })
}

variable "docker_images" {
  description = "Docker images"
  type = object({
    vault_agent_image   = string
    consul_client_image = string
    nomad_image         = string
  })
}

variable "container_data_directory" {
  description = "Container data directory"
  type        = string
  default     = null
}

variable "docker_host" {
  description = "Docker host to connect to"
  type = object({
    hostname     = string
    username     = string
    ip           = string
    fqdn         = string
    domain       = string
    bastion_host = optional(string, null)
    bastion_user = optional(string, null)
  })
}
