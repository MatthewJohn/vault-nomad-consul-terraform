
variable "hostname" {
  description = "Hostname"
  type        = string
}

variable "port" {
  description = "Port for loki to listen on"
  type        = string
  default     = 3100
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "docker_username" {
  description = "SSH username to connect to docker host"
  type        = string
}

variable "docker_host" {
  description = "Docker host to connect to"
  type        = string
}

variable "docker_ip" {
  description = "IP Address of docker host"
  type        = string
}
