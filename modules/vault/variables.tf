
variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

variable "vault_version" {
  description = "Vault version"
  type = string
  default = "1.13.2"
}

variable "hostname" {

}

variable "docker_host" {

}

variable "docker_username" {
  description = "Username to connect to docker host"
  type        = string
  default     = "docker-connect"
}

variable "docker_ip" {

}
