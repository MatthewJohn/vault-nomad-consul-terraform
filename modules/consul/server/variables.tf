
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
    s3_key_public_key  = string
    s3_key_private_key = string
  })
}

# variable "consul_domain" {
#   description = "Consul domain"
#   type        = string
# }

# variable "root_ca_s3_bucket" {
#   description = "S3 bucket holding root CA"
#   type        = string
# }

# variable "root_ca_s3_key_public_key" {
#   description = "S3 key for CA public key in root CA S3 bucket"
#   type        = string
# }

# variable "root_ca_s3_key_private_key" {
#   description = "S3 key for CA private key in root CA S3 bucket"
#   type        = string
# }

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
