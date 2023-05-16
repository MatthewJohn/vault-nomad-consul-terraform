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

  disk {
    block_device = "/dev/ssd-1/${var.name}-disk-1"
  }

  boot_device {
    dev = [ "cdrom", "hd"]
  }
}