resource "libvirt_domain" "this" {
  name = var.name

  memory = var.memory

  running = true
  autostart = false
  fw_cfg_name = null


#   cloudinit = 

  network_interface {
    network_name = "default"
  }

  # disk {
  #   block_device = "/dev/ssd-1/${var.name}-disk-1"
  # }

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
}