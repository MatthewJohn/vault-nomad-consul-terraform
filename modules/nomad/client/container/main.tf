resource "null_resource" "container_image" {
  triggers = {
    image = var.image
  }
}

resource "docker_container" "this" {
  image = var.image

  name    = "nomad-client"
  rm      = false
  restart = "always"

  hostname   = "${var.docker_host.hostname}.${var.datacenter.common_name}"
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

  mounts {
    target = "/nomad/data"
    type   = "bind"
    source = "/nomad/data"
    bind_options {
      propagation = "shared"
    }
  }

  mounts {
    target = "/nomad/config"
    type   = "bind"
    source = "/nomad/config"
    bind_options {
      propagation = "shared"
    }
  }

  volumes {
    container_path = "/nomad/vault"
    host_path      = "/nomad/vault"
    read_only      = true
  }

  mounts {
    target = "/vault-agent-consul-template/auth"
    type   = "bind"
    source = var.consul_template_vault_agent.token_directory
    bind_options {
      propagation = "shared"
    }
  }

  # Mount cgroup due to errors when running client
  # [WARN]  client.fingerprint_mgr.cpu: failed to detect set of reservable cores: error="openat2 /sys/fs/cgroup/nomad.slice/cpuset.cpus.effective: no such file or directory"
  # [WARN]  client.fingerprint_mgr.landlock: failed to fingerprint kernel landlock feature: error="function not implemented"
  # [ERROR] agent: error starting agent: error="client setup failed: fingerprinting failed: Error while detecting network interface  during fingerprinting: fork/exec /sbin/ip: no such file or directory"
  volumes {
    container_path = "/sys/fs/cgroup"
    host_path      = "/sys/fs/cgroup"
  }

  # Pass through docker socket/docker runtime for client and fix issues with netns errors
  mounts {
    target = "/var/run"
    type   = "bind"
    source = "/var/run"
    bind_options {
      propagation = "shared"
    }
  }
  # Use shared mounts to fix issues with CNI tools reading netns
  mounts {
    target = "/var/run/docker/netns"
    type   = "bind"
    source = "/var/run/docker/netns"
    bind_options {
      propagation = "shared"
    }
  }

  # Pass through data volume for client
  dynamic "mounts" {
    for_each = toset(var.container_data_directory != null ? [var.container_data_directory] : [])

    content {
      target = mounts.value
      type   = "bind"
      source = mounts.value
      bind_options {
        propagation = "shared"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      log_opts,
      image,
    ]

    replace_triggered_by = [
      null_resource.nomad_config,
      null_resource.container_image,
    ]
  }
}
