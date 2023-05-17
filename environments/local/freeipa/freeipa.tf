# Create FreeIPA docker container
resource "docker_container" "freeipa" {
  image = "freeipa/freeipa-server:centos-7-4.6.8"

  name = "freeipa${var.initial_setup ? "-setup" : ""}"
  rm = false
  restart = var.initial_setup ? "no" : "on-failure"

  hostname = "freeipa"
  domainname = "dock.local"

  sysctls = {
    "net.ipv6.conf.all.disable_ipv6" = "0"
    "net.ipv6.conf.eth0.disable_ipv6" = "1"
    "net.ipv6.conf.lo.disable_ipv6" = "0"
  }

  command = concat(
    var.initial_setup ? [
      "ipa-server-install", "--hostname", "freeipa.dock.local"
    ] : [],
    [
      "-U", "--auto-forwarders",
      "-r", "DOCK.LOCAL", "--setup-dns", "--ds-password", "dirpassword",
      "--no-dnssec-validation", "--no-host-dns",
      "--admin-password", var.freeipa_password
    ]
  )

  env = concat(
    [
      "DEBUG_TRACE=1"
    ],
    var.initial_setup == false ? ["DEBUG_NO_EXIT=1"] : []
  )

  volumes {
    container_path = "/sys/fs/cgroup"
    host_path = "/sys/fs/cgroup"
    read_only = true
  }

  volumes {
    container_path = "/data"
    host_path = "/tmp/freeipa-data"
  }

  lifecycle {
    ignore_changes = [image]
  }
}