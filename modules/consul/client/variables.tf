variable "listen_port" {
  description = "Port for consul client to listen on"
  type        = number
  default     = 8501
}

variable "listen_host" {
  description = "Host for consul client to listen on"
  type        = string
  default     = "127.0.0.1"
}

variable custom_role {
  type = object({
    approle_name      = string
    vault_consul_role = string
  })
  default = null
}

variable use_token_as_default {
  description = "Whether to use token for inbound connections, authenticating anonymous clients as this consul client's role"
  type        = bool
  default     = false
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
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
    ca_cert                  = string
  })
}

variable "root_cert" {
  description = "Root certificate object"
  type = object({
    pki_mount_path         = string
    common_name            = string
    organisation           = string
    ou                     = string
    pki_connect_mount_path = string
  })
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

variable "docker_images" {
  description = "Docker images"
  type = object({
    vault_agent_image   = string
    consul_client_image = string
  })
}
