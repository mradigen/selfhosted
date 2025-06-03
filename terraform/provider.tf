terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc9"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
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

variable "homeassistant_ipconfig0" {
  type      = string
  default = ""
}

provider "proxmox" {

  # Proxmox
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true

}

provider "ansible" { }
