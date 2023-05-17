output "ip_address" {
  value = docker_container.freeipa.network_data[0].ip_address
}