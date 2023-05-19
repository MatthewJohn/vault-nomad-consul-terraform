
data "external" "init_vault" {
  program = [
    "bash",
    "${path.module}/init_secondary.sh",
    var.vault_host,
    var.host_ssh_username,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    var.bucket_name,
    var.autoseal_token_file,
    var.initial_run == true ? "1" : "0"
  ]
}
