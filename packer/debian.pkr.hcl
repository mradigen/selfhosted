packer {
	required_plugins {
		proxmox = {
			version = "~> 1"
			source  = "github.com/hashicorp/proxmox"
		}
	}
}

variable "proxmox_api_url" {
	type = string
}

variable "proxmox_api_token_id" {
	type = string
	sensitive = true
}

variable "proxmox_api_token_secret" {
	type      = string
	sensitive = true
}

variable "proxmox_vm_id" {
	type      = string
	default   = "901"
}

variable "proxmox_node" {
	type      = string
}

source "proxmox-iso" "debian" {
	# Proxmox API connection
	proxmox_url              = var.proxmox_api_url
	username                 = var.proxmox_api_token_id
	token                    = var.proxmox_api_token_secret
	insecure_skip_tls_verify = true

	# VM
	node                  = var.proxmox_node
	vm_name               = "Debian12"
	vm_id                 = var.proxmox_vm_id
	template_description  = "Debian 12 (bookworm)"

	# Disks
	scsi_controller = "virtio-scsi-single"
	disks {
		disk_size     = "5G"
		format        = "raw"
		storage_pool  = "local-lvm"
		type          = "scsi"
		discard       = true
		io_thread     = true
	}

	# Network
	network_adapters {
		bridge   = "vmbr0"
		firewall = true
		model    = "virtio"
	}

	# Boot stuff, serve preseed.cfg over built-in HTTP
	http_directory = "./http"
	boot_wait      = "10s"
	boot_command   = [
		"<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
	]

	# ISO
	boot_iso {
		type     = "scsi"
		# iso_url  = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
		# iso_checksum = "sha256:30ca12a15cae6a1033e03ad59eb7f66a6d5a258dcf27acd115c2bd42d22640e8"
		iso_file = "local:iso/debian-12.10.0-amd64-netinst.iso"
		iso_storage_pool = "local"
		unmount  = true
	}

	# Hardware
	cpu_type = "x86-64-v2-AES"
	memory   = "4096"
	sockets  = "1"
	cores    = "2"

	ssh_username = "root"
	ssh_password = "packer"

	# VM Cloud-Init Settings
	cloud_init = true
	cloud_init_storage_pool = "local-lvm"
}

build {
	sources = ["source.proxmox-iso.debian"]

	provisioner "shell" {
		inline = [
			# Cleanup
			# "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
			"rm /etc/ssh/ssh_host_*",
			"truncate -s 0 /etc/machine-id",
			"apt -y autoremove --purge",
			"apt -y clean",
			"apt -y autoclean",
			"cloud-init clean",
			"rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
			"sync",

			# Set authorized_keys (not needed now, using cloud-init for that)
			# "mkdir -p /root/.ssh",
			# "echo '${var.root_authorized_keys}' > /root/.ssh/authorized_keys",
			# "chmod 700 /root/.ssh",
			# "chmod 600 /root/.ssh/authorized_keys",
			"sed -e 's/PermitRootLogin yes/#PermitRootLogin prohibit-password/' -i /etc/ssh/sshd_config",

			# System updates and guest agent, its already done in the preseed.cfg, regardless why not do it here
			# "apt-get update && apt-get upgrade -y",
			# "apt-get install -y qemu-guest-agent cloud-init",
		]
	}

	provisioner "file" {
		source = "./http/99-grow-root.cfg"
		destination = "/etc/cloud/cloud.cfg.d/99-grow-root.cfg"
	}
}
