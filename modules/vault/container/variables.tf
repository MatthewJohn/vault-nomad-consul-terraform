variable "docker_username" {
  description = "SSH username to connect to docker host"
  type        = string
}

variable "docker_host" {
  description = "Docker host to connect to"
  type        = string
}

variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "image" {
  description = "Image to be used"
  type        = string
}
