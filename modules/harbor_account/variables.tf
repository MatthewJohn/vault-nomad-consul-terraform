variable "harbor_account" {
  description = "Harbor account secret"
  type = object({
    secret_mount = string
    secret_name  = string
  })
}

variable "harbor_projects" {
  description = "List of required harbor project access"
  type        = list(string)
}
