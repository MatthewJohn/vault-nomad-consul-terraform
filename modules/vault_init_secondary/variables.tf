
variable "vault_host" {
  description = "Node domain of main vault node"
  type        = string
}

variable "host_ssh_username" {
  description = "SSH username to connect vault host"
  type        = string
}

variable "aws_profile" {
  description = "Name of AWS profile"
  type        = string
}

variable "aws_endpoint" {
  description = "AWS Endpoint URL"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name to store unseal and root credentials"
  type        = string
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
}

variable "autoseal_token_file" {
    description = "Bucket key for autoseal token file"
    type        = string
}

