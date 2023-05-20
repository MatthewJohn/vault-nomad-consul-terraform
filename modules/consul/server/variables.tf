
variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "datacenter" {
  description = "Consul datacenter"
  type        = string
}

variable "root_ca" {
  description = "Output of root CA module"
  type = object({
    domain_name        = string
    s3_bucket          = string
    s3_prefix = string
    s3_key_public_key  = string
    s3_key_private_key = string
  })
}

variable "consul_binary" {
  description = "Consul binary path"
  type        = string
}

variable "consul_version" {
  description = "Version of consul"
  type        = string
}

variable "initial_run" {
  description = "Whether to allow creation of root CA"
  type        = bool
  default     = false
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
