variable "vyria_username" {
  type      = string
}

variable "vyria_root_sshkey" {
  type      = string
}

variable "vyria_ipconfig0" {
  type      = string
  default = ""
}

variable "vyria_ssh_port" {
  type      = number
  default = 22
}

resource "proxmox_vm_qemu" "Vyria" {
  name = "Vyria"
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

  memory = 4096

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
  sshkeys     = var.vyria_root_sshkey
  disk {
    slot    = "scsi10" # this is ignored when using cloudinit but for some reason fails if not mentioned
    type    = "cloudinit"
    storage = "local-lvm"
    size    = "8M"
  }
  ipconfig0 = var.vyria_ipconfig0
}

#########################################################
# DOESNT WORK:
#########################################################

resource "ansible_host" "vyria" {
  # name = proxmox_vm_qemu.Vyria
  name = "192.168.29.250"
  variables = {
    ansible_user = "root",
    # ansible_port = "22"
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519"
  }

  depends_on = [proxmox_vm_qemu.Vyria]
}

resource "ansible_playbook" "vyria-playbook" {
  playbook   = "../ansible/Vyria.yml"
  # use_provider_inventory = true
  name       = proxmox_vm_qemu.Vyria
  replayable = false

  extra_vars = {
    username = var.vyria_username
    ssh_port = var.vyria_ssh_port
    network_interface = "ens18"
    # tailscale_preauthkey = var.tailscale_preauth_key
  }

  depends_on = [ansible_host.vyria]
}
