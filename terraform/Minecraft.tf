variable "minecraft_root_sshkey" {
  type      = string
}

variable "minecraft_ipconfig0" {
  type      = string
  default = ""
}

resource "proxmox_vm_qemu" "Minecraft" {
  name = "Minecraft"
  target_node = "Vyria"
  vmid = 103

  onboot = true
  # QEMU agent
  agent = 1

  clone = "Debian12"

  cpu {
    type = "x86-64-v2-AES"
    sockets = 1
    cores = 4
  }

  memory = 6144

  network {
    id = 0
    bridge = "vmbr0"
    model = "virtio"
    firewall = false
  }

  boot = "order=scsi0;net0"

  scsihw = "virtio-scsi-single"
  disk {
    slot		= "scsi0"
    size		= "10G"
    storage		= "local-lvm"
    iothread	= true
    discard		= true
  }

  # cloud-init:
  ciuser      = "root"
  sshkeys     = var.minecraft_root_sshkey
  disk {
    slot    = "scsi10" # this is ignored when using cloudinit but for some reason fails if not mentioned
    type    = "cloudinit"
    storage = "local-lvm"
    size    = "8M"
  }
  ipconfig0 = var.minecraft_ipconfig0
}
