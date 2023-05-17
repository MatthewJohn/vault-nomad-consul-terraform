resource "libvirt_domain" "this" {
  name = var.name

  memory = var.memory

  running = true
  autostart = false
  fw_cfg_name = null


  cloudinit = libvirt_cloudinit_disk.this.id

  network_interface {
    bridge = "virbr0"
    # network_name = "default"
    mac = macaddress.this.address
  }

  ## Investigate <driver name='qemu' type='raw' cache='directsync'/>
  disk {
    block_device = local.disk_is_block_device ? "${local.base_disk_path}/${var.name}-disk-1" : null
    file = local.disk_is_block_device ? null : "${local.base_disk_path}/${var.name}-disk-1"
  }

  cpu {
    mode = "host-passthrough"
  }

  vcpu = var.vcpu_count
  machine = "pc-1.0"

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  video {
    type = "vmvga"
    vram = 16384
  }

  boot_device {
    dev = [ "cdrom", "hd"]
  }

  # serial {
  #   target_port = "0"
  #   type = "pty"
  # }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  lifecycle {
    ignore_changes = [disk[0].volume_id, disk[0].file]
  }

  depends_on = [
    null_resource.create_disk,
    null_resource.copy_template
  ]

}