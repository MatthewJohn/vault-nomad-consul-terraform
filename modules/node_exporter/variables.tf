
variable "hostname" {
  description = "Hostname"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "docker_host" {
  description = "Docker host configuration"
  type = object({
    ip_address      = string
    docker_username = string
    fqdn            = string
  })
}
