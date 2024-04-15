
variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

variable "vault_subdomain" {
  description = "Subdomain of primary domain for vault"
  type        = string
  default     = "vault"
}

variable "setup_host" {
  description = "Hostname of vault host to use during initial setup"
  type        = string
}

variable "ip_addresses" {
  description = "List of all vault IP Addresses"
  type        = list(string)
  default     = []
}

variable "ca_cert_file" {
  description = "Path to root certificate"
  type        = string
}

variable "admin_policy_name" {
  description = "Name of policy to create for admins"
  type        = string
  default     = "vault-admin"
}

variable "terraform_policy_name" {
  description = "Name of policy to create for terraform"
  type        = string
  default     = "terraform"
}

variable "root_token" {
  description = "Root token to authenticate to cluster"
  type        = string
}

variable "consul_datacenters" {
  description = "List of consul datacenter to provide permissions to Terraform user"
  type        = list(string)
  default     = []
}

variable "nomad_regions" {
  description = "Map of noamd regions and child list of datacenter"
  type        = map(list(string))
  default     = {}
}

variable "gitlab_url" {
  description = "Gitlab URL for JWT authentication"
  type        = string
  default     = null
}

variable "ldap" {
  description = "LDAP authentication details"
  type = object({
    url         = string
    userdn      = string
    userattr    = string
    userfilter  = optional(string, null)
    groupdn     = string
    groupfilter = optional(string, null)
    certificate = optional(string, null)
    admin_group = optional(string, "vault-admins")
  })
  default = null
}
