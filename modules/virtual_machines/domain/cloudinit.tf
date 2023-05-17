data "template_file" "user_data" {
  template = <<EOF
#cloud-config
password: password
chpasswd:
  expire: False
ssh_pwauth: True
ssh_authorized_keys:
  - ssh-rsa ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcGH/YaonGEDCKOwx8IX9OwihRJ7OkINQYxx1bTnB+9EQQGPEMbzTMWQWFPamlNLdhdutQuRS4CWASAW3S+jDqbEy4KIngW1hNzEdS+pd2xoAm9jdd7Xv46n6YYfC6tTMMY/mvX3cUJmFMDEpHMCEALOkQR55vCNp3ru7Slm5Jb8Ou6QzGrNMYZmrIfgaclq6qHE/eRDqah7vo8ufXwFmtNk7BXc9cV///6fHUg7oGeYgjCtyRiNUIKarI4fFAcsDOfaXX9RQuPUfAs+7qCMJ78dMnjmpQM5YQenuaraunitLVLLTFDXD1tIHV4KUoStOF3aBuonDWshZuE8GntzmY5kKqKWoKcycU/HrlnhMaWlzj1xgh6TwW1XgLrttPqL3+jbBs65Z+1HTWAxjgcm88tSG/3B1+SJCsWGnK6WpESlJ4vpvXbxgJB5nZDXlc/J9ncxD0meCYSMjOvZYjHLOp58n0WAx3JstMVi/BHQ4ekVc+lxwgfFz2VPy8mNO0PWGqSDdWrIUSCjw0+ujvmUgCoj5S/5LwvMyZQj9wyQBwANFeY+D+Dn5vwDK+A7kUz/KM5u6zoU0UF5QwAVmDuChiYnIRI4EtL5DkmclbMKTZcbNQtN4OuliehIZB94sHu9d2L6k10hX/V5NW+ezczu5LQtbxbx9L1CQAXhF3FQqfXw== matthew@laptop21
users:
  - default
  - name: ds
    primary_group: ds
    groups: users
    expiredate: '2032-09-01'
    lock_passwd: true
  - name: docker-connect
    primary_group: docker-connect
    groups: users
    lock_passwd: true
    ssh_authorized_keys:
      - ${var.docker_ssh_key}


runcmd:
  # Install docker, as per https://docs.docker.com/engine/install/debian/
  - apt-get update && apt-get install ca-certificates curl gnupg --assume-yes &&
    install -m 0755 -d /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    chmod a+r /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" > /etc/apt/sources.list.d/docker.list &&
    apt-get update &&
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --assume-yes &&
    mkdir -p /etc/docker &&
    echo '{"default-address-pools": [{"base":"10.10.0.0/24","size":24}]}' > /etc/docker/daemon.json &&
    systemctl enable docker && systemctl restart docker &&
    usermod -aG docker docker-connect

EOF
}

data "template_file" "network_config" {
  template = <<EOF
version: 2
ethernets:
  ens3:
    dhcp4: false
    dhcp6: false
    addresses: [${var.ip_address}]
    gateway4: ${var.ip_gateway}
    nameservers:
      search: [${var.domain_name}]
      addresses: [${join(", ", var.nameservers)}]

EOF
}

resource "random_id" "instance_id" {
  keepers = {
    # Generate a new id each time we switch name
    name = var.name
  }

  byte_length = 8
}

data "template_file" "meta_data" {
  template = <<EOF
instance-id: i-${random_id.instance_id.hex}
local-hostname: ${var.name}.${var.domain_name}
EOF
}


resource "libvirt_cloudinit_disk" "this" {
  name           = "${var.name}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  meta_data      = data.template_file.meta_data.rendered
}
