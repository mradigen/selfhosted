variable "homeassistant_ipconfig0" {
  type      = string
  default = ""
}

resource "proxmox_vm_qemu" "HomeAssistant" {
	name        = "HomeAssistant"
	vmid = "109"
	target_node = "Beta"

	vm_state = "stopped"

	machine = "q35"
	bios    = "ovmf"
	agent = 1
	onboot  = true

	memory  = 2048
	cpu {
		type = "kvm64"
		sockets = 1
		cores = 2
	}

	# Disk will be attached from commands
	scsihw = "virtio-scsi-single"

	ipconfig0 = var.homeassistant_ipconfig0
	network {
		id = 0
		model  = "virtio"
		bridge = "vmbr0"
	}
}

# After doing terraform apply: 
# SSH into the server: `ssh root@${var.beta_hostip} -p 22`
#
# Run the following on the Beta Host proxmox node:
# wget https://github.com/home-assistant/operating-system/releases/download/15.2/haos_ova-15.2.qcow2.xz
# unxz haos_ova-15.2.qcow2.xz
# qm importdisk 109 ./haos_ova-15.2.qcow2 local-lvm --format qcow2
#
# Once done:
# Go to proxmox, navigate to HomeAssistant, and enable Discard on the unused disk
# Change the boot order to only allow ide0 (the imported disk) to boot
