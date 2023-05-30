
resource "docker_container" "this" {
  image = var.image

  name    = "nomad-client"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.datacenter.common_name}"
  domainname = ""

  command = concat(
    [
      "nomad", "agent", "-config", "/nomad/config/client.hcl"
    ]
  )

  user = "root"

  # Use privileged mode to allow listening on any port
  privileged = true

  network_mode = "host"

  env = [
    # "VAULT_ROOT_CA_CERT=${var.vault_cluster.root_ca_cert}"
    # "VAULT_TOKEN="
  ]

  volumes {
    container_path = "/nomad/data"
    host_path      = "/nomad/data"
  }

  volumes {
    container_path = "/nomad/config"
    host_path      = "/nomad/config"
  }

  volumes {
    container_path = "/nomad/vault"
    host_path      = "/nomad/vault"
    read_only      = true
  }

  volumes {
    container_path = "/vault-agent-consul-template/auth"
    host_path      = var.consul_template_vault_agent.token_directory
  }

  # Mount cgroup due to errors when running client
  # [WARN]  client.fingerprint_mgr.cpu: failed to detect set of reservable cores: error="openat2 /sys/fs/cgroup/nomad.slice/cpuset.cpus.effective: no such file or directory"
  # [WARN]  client.fingerprint_mgr.landlock: failed to fingerprint kernel landlock feature: error="function not implemented"
  # [ERROR] agent: error starting agent: error="client setup failed: fingerprinting failed: Error while detecting network interface  during fingerprinting: fork/exec /sbin/ip: no such file or directory"
  volumes {
    container_path = "/sys/fs/cgroup"
    host_path      = "/sys/fs/cgroup"
  }

  # Pass through docker socket for client
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  volumes {
    container_path = "/var/run/docker"
    host_path      = "/var/run/docker"
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.nomad_config
    ]
  }
}
