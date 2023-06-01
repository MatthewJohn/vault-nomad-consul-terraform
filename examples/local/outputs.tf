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

locals {
  aws_config = <<EOF
cat > ~/.aws/config <<EOS
[profile dockstudios-terraform]
region = main
output = json

[profile dockstudios-admin-terraform]
region = main
output = json
EOS

cat ~/.aws/credentials <<EOS
[dockstudios-terraform]
aws_access_key_id=${module.s3_configure.terraform_access_key}
aws_secret_access_key=${nonsensitive(module.s3_configure.terraform_secret_key)}

[dockstudios-admin-terraform]
aws_access_key_id=${module.s3_configure.admin_terraform_access_key}
aws_secret_access_key=${nonsensitive(module.s3_configure.admin_terraform_secret_key)}
EOS

EOF
}

output "aws_config" {
  value = local.aws_config
}
