
variable "nomad_host" {
  description = "Nomad hot to perform bootstrapping on"
  type = object({
    docker_host      = string
    docker_username  = string
    nomad_https_port = number
  })
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
  description = "Bucket name to store bootstrap credentials"
  type        = string
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
}
