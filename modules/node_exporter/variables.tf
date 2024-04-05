variable "docker_host" {
  description = "Docker host configuration"
  type = object({
    username = string
    fqdn     = string
  })
}
