
variable "hostname" {
  description = "Hostname for consule server"
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
    s3_prefix          = string
    s3_key_public_key  = string
    s3_key_private_key = string
  })
}

variable "initial_run" {
  description = "Whether to allow creation of root CA"
  type        = bool
  default     = false
}

variable "ip_address" {
  description = "IP Address for the certificate"
  type        = string
}

variable "additional_domains" {
  description = "List of additional host domains for the server"
  type        = list(string)
  default     = []
}

variable "expiry_days" {
  description = "Expiration in days (default 1 year)"
  type        = number
  default     = 3650
}

variable "consul_binary" {
  description = "Consul binary path"
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
