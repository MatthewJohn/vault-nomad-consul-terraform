variable "image" {
  description = "Image to be used"
  type        = string
}

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
    name                                      = string
    common_name                               = string
    role_name                                 = string
    pki_mount_path                            = string
    approle_mount_path                        = string
    server_dns                                = string
    server_vault_policy                       = string
    server_vault_role                         = string
    server_consul_template_consul_server_role = string
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

variable "consul_template_vault_agent" {
  description = "Vault agent instance for consul template"
  type = object({
    container_id    = string
    token_directory = string
    token_path      = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                     = string
    ca_chain                 = string
    consul_engine_mount_path = string
  })
}

variable "consul_client" {
  description = "Configuration of consul client"
  type = object({
    port        = number
    listen_host = string
  })
}

variable "consul_token" {
  description = "Details for consul token"
  type = object({
    mount = string
    name  = string
  })
}

variable "nomad_https_port" {
  description = "Nomad HTTPS listen port"
  type        = number
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
}

variable "docker_host" {
  description = "Docker host to connect to"
  type = object({
    ip           = string
    username     = string
    hostname     = string
    fqdn         = string
    bastion_host = optional(string, null)
    bastion_user = optional(string, null)
  })
}
