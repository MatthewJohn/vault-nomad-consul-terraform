output "virtual_machines" {
  description = "Virtual machine configs"
  value = {
    for host, config in merge(
      var.vault_hosts,
      var.consul_hosts,
      var.nomad_server_hosts,
      var.nomad_client_hosts,
      var.storage_server != null ? { "${var.storage_server.name}" = var.storage_server } : {},
      var.monitoring_server != null ? { "${var.monitoring_server.name}" = var.monitoring_server } : {},
    ) :
    host => {
      ip_address      = config["ip_address"]
      docker_username = "docker-connect"
      fqdn            = "${host}.${var.domain_name}"
      hostname        = host
      domain_name     = var.domain_name
    }
  }
}