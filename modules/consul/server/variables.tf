variable "docker_host" {
  description = "Docker host"
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

variable "datacenter" {
  description = "Consul datacenter"
  type = object({
    name                                     = string
    common_name                              = string
    role_name                                = string
    pki_mount_path                           = string
    agent_consul_template_policy             = string
    static_mount_path                        = string
    consul_engine_mount_path                 = string
    approle_mount_path                       = string
    server_consul_template_approle_role_name = string
    pki_connect_mount_path                   = string
    connect_ca_approle_role_name             = string
    consul_server_token = object({
      mount = string
      name  = string
    })
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

variable "app_cert" {
  description = "App certificate object"
  type = object({
    common_name = string
  })
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
}

variable "http_proxy" {
  description = "HTTP proxy URL"
  type        = string
}

variable "consul_version" {
  description = "Version of consul"
  type        = string
}
