
variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "datacenter" {
  description = "Consul datacenter"
  type        = string
}

variable "consul_version" {
  description = "Version of consul"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "aws_region" {
  description = "AWS profile"
  type        = string
}

variable "aws_endpoint" {
  description = "AWS s3 endpoint"
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
