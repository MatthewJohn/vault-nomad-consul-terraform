output "binary_path" {
  description = "Path of consul binary"
  # Trigger based on ID of null resource,
  # so that it's only available once the local-exec
  # has completed
  value = null_resource.download_and_extract.id != "" ? "./consul-${var.consul_version}" : null
}

output "consul_version" {
  description = "Version of consul in use"
  value       = var.consul_version
}
