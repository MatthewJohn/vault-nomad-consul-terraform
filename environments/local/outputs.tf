output "admin_terraform_access_key" {
  value = module.s3_configure.admin_terraform_access_key
}

output "admin_terraform_secret_key" {
  value = nonsensitive(module.s3_configure.admin_terraform_secret_key)
}

output "terraform_access_key" {
  value = module.s3_configure.terraform_access_key
}

output "terraform_secret_key" {
  value = nonsensitive(module.s3_configure.terraform_secret_key)
}
