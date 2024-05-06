variable "image" {
  description = "Image to be used"
  type        = string
}

variable "datacenter" {
  description = "Consul datacenter"
  type = object({
    name                         = string
    common_name                  = string
    role_name                    = string
    pki_mount_path               = string
    agent_consul_template_policy = string
    static_mount_path            = string
    consul_engine_mount_path     = string
    approle_mount_path           = string
    pki_connect_mount_path       = string
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

variable "app_cert" {
  description = "App certificate object"
  type = object({
    common_name = string
  })
}

variable "consul_template_vault_agent" {
  description = "Vault agent instance for consul template"
  type = object({
    container_id    = string
    token_directory = string
    token_path      = string
  })
}


variable "connect_ca_approle_role_id" {
  description = "Approle role ID for connect CA"
  type        = string
}

variable "connect_ca_approle_secret_id" {
  description = "Approle secret ID for connect CA"
  type        = string
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
}

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