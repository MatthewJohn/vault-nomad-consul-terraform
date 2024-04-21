variable "image" {
  description = "Image to be used"
  type        = string
}

variable "listen_port" {
  description = "Port for consul client to listen on"
  type        = number
}

variable "listen_host" {
  description = "Host for consul client to listen on"
  type        = string
}

variable "app_role_id" {
  description = "App role ID for authentication"
  type        = string
}

variable "app_role_secret" {
  description = "App role secret for authentication"
  type        = string
}

variable "app_role_mount_path" {
  description = "Mount path for approle backend"
  type        = string
}

variable "datacenter" {
  description = "Consul datacenter"
  type = object({
    name                     = string
    common_name              = string
    pki_mount_path           = string
    static_mount_path        = string
    consul_engine_mount_path = string
    approle_mount_path       = string
    pki_connect_mount_path   = string
    client_ca_role_name      = string
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
