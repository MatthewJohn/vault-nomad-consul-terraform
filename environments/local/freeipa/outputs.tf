output "freeipa_ip" {
  value = docker_container.freeipa.network_data[0].ip_address
}