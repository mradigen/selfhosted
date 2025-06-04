variable "kubernetes1_root_sshkey" {
  type      = string
}

variable "kubernetes1_ipconfig0" {
  type      = string
  default = ""
}

resource "proxmox_vm_qemu" "Kubernetes1" {
  name = "Kubernetes1"
  desc = "Main Debian node running all services through Docker Compose"
  target_node = "Vyria"

  onboot = true
  # QEMU agent
  agent = 1

  clone = "Debian12"

  cpu {
    type = "x86-64-v2-AES"
    sockets = 1
    cores = 4
  }

  memory = 2048

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
  sshkeys     = var.kubernetes1_root_sshkey
  disk {
    slot    = "scsi10" # this is ignored when using cloudinit but for some reason fails if not mentioned
    type    = "cloudinit"
    storage = "local-lvm"
    size    = "8M"
  }
  ipconfig0 = var.kubernetes1_ipconfig0
}
