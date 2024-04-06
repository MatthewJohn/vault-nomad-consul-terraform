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
    client_consul_template_approle_role_name = string
    client_dns                               = string
    pki_mount_path                           = string
    client_pki_role_name                     = string
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

variable "consul_root_cert" {
  description = "Consul root certificate authority"
  type = object({
    public_key = string
  })
}

variable "nomad_client_vault_consul_role" {
  description = "Name of vault consul engine role for nomad client"
  type        = string
}

variable "docker_host" {
  description = "Docker host to connect to"
  type        = object({
    hostname     = string
    username     = string
    ip           = string
    fqdn         = string
    domain       = string
    bastion_host = optional(string, null)
    bastion_user = optional(string, null)
  })
}
