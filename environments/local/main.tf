
locals {
  freeipa_admin = "admin"
  freeipa_password = "password"
}

# Create FreeIPA docker container
resource "docker_container" "freeipa_setup" {
  image = "freeipa/freeipa-server:rocky-9"

  name = "freeipa-setup2"
  command = [
    "ipa-server-install", "-U", "--hostname", "freeipa.dock.local", "--auto-forwarders",
    "-r", "DOCK.LOCAL", "--setup-dns", "--ds-password", "dirpassword", "--no-dnssec-validation",
    "--admin-password", local.freeipa_password
  ]
  rm = false
  hostname = "freeipa"
  domainname = "dock.local"
  sysctls = {
    "net.ipv6.conf.all.disable_ipv6" = "0"
    "net.ipv6.conf.eth0.disable_ipv6" = "1"
    "net.ipv6.conf.lo.disable_ipv6" = "0"
  }

  volumes {
    container_path = "/sys/fs/cgroup"
    host_path = "/sys/fs/cgroup"
    read_only = true
  }

  volumes {
    container_path = "/data"
    host_path = "/tmp/freeipa-data"
  }

}

resource "docker_container" "freeipa" {
  image = "freeipa/freeipa-server:rocky-9"

  name = "freeipa"
  rm = false
  restart = "on-failure"
  hostname = "freeipa"
  domainname = "dock.local"
  #command = ["freeipa-server"]
  sysctls = {
    "net.ipv6.conf.all.disable_ipv6" = "0"
    "net.ipv6.conf.eth0.disable_ipv6" = "1"
    "net.ipv6.conf.lo.disable_ipv6" = "0"
  }

  command = [
    "-U", "--hostname", "freeipa.dock.local", "--auto-forwarders",
    "-r", "DOCK.LOCAL", "--setup-dns", "--ds-password", "dirpassword",
    "--no-dnssec-validation", "--no-host-dns",
    "--admin-password", local.freeipa_password
  ]


  env = [
    "DEBUG_TRACE=1",
    "DEBUG_NO_EXIT=1"
  ]

  volumes {
    container_path = "/sys/fs/cgroup"
    host_path = "/sys/fs/cgroup"
    read_only = true
  }

  volumes {
    container_path = "/data"
    host_path = "/tmp/freeipa-data"
  }

}

module "this" {
  source = "../../"
}


provider "docker" {
  alias = "local"
}


