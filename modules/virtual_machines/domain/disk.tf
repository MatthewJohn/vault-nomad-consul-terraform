resource "null_resource" "download_disk_template" {
  connection {
    type = "ssh"
    user = var.hypervisor_username
    host = var.hypervisor_hostname
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -f '${local.base_disk_path}/${var.image_name}' ]; then curl -o '${local.base_disk_path}/${var.image_name}' '${var.image_source_url}'; fi"
    ]
  }
}

resource "null_resource" "create_disk" {
  connection {
    type = "ssh"
    user = var.hypervisor_username
    host = var.hypervisor_hostname
  }

  provisioner "remote-exec" {
    inline = local.disk_is_block_device ? [
      # @TODO Handle raw disk creation
      ] : [
      "if [ ! -f '${local.base_disk_path}/${local.disk_name}' ]; then dd if=/dev/zero of='${local.base_disk_path}/${local.disk_name}' bs=1M count=${var.disk_size}; fi"
    ]
  }
}

resource "null_resource" "copy_template" {
  connection {
    type = "ssh"
    user = var.hypervisor_username
    host = var.hypervisor_hostname
  }

  provisioner "remote-exec" {
    inline = local.disk_is_block_device ? [
      # @TODO Handle raw disk creation
      ] : [
      <<EOF
set -e
set -x

if [ ! -f '${local.base_disk_path}/.${local.disk_name}-templated' ]
then
  qemu-img convert -n -f qcow2 -O raw '${local.base_disk_path}/${var.image_name}' '${local.base_disk_path}/${local.disk_name}'
  touch '${local.base_disk_path}/.${local.disk_name}-templated'
fi
EOF
    ]
  }

  depends_on = [
    null_resource.create_disk
  ]
}

