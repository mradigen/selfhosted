<div align="center">

# Homelab

[![Baikal](https://img.shields.io/badge/-Baikal-black?style=for-the-badge&logo=googlecalendar)](https://sabre.io/baikal/) [![Balti](https://img.shields.io/badge/-Balti-black?style=for-the-badge&logo=bitbucket)](https://github.com/) [![Balti MinIO](https://img.shields.io/badge/-Balti%20MinIO-black?style=for-the-badge&logo=minio)](https://min.io/) [![Borgmatic](https://img.shields.io/badge/-Borgmatic-black?style=for-the-badge&logo=borgbackup)](https://torsion.org/borgmatic/) [![Chota](https://img.shields.io/badge/-Chota-black?style=for-the-badge&logo=curl)](https://github.com/) [![Flatnotes](https://img.shields.io/badge/-Flatnotes-black?style=for-the-badge&logo=markdown)](https://github.com/dullage/flatnotes) [![Syncthing](https://img.shields.io/badge/-Syncthing-black?style=for-the-badge&logo=syncthing)](https://syncthing.net/) [![Headscale](https://img.shields.io/badge/-Headscale-black?style=for-the-badge&logo=tailscale)](https://headscale.net/) [![HomeAssistant](https://img.shields.io/badge/-HomeAssistant-black?style=for-the-badge&logo=homeassistant)](<[https://github.com/dani-garcia/vaultwarden](https://www.home-assistant.io/)>) [![Immich](https://img.shields.io/badge/-Immich-black?style=for-the-badge&logo=immich)](https://immich.app/) [![Kachra](https://img.shields.io/badge/-Kachra-black?style=for-the-badge&logo=pastebin)](https://github.com/) [![n8n](https://img.shields.io/badge/-n8n-black?style=for-the-badge&logo=n8n)](https://n8n.io/) [![Paperless NGX](https://img.shields.io/badge/-Paperless%20NGX-black?style=for-the-badge&logo=paperlessngx)](https://docs.paperless-ngx.com/) [![Traefik](https://img.shields.io/badge/-Traefik-black?style=for-the-badge&logo=traefikproxy)](https://traefik.io/) [![TUI Suite](https://img.shields.io/badge/-TUI%20Suite-black?style=for-the-badge&logo=termius)](https://github.com/) [![Vaultwarden](https://img.shields.io/badge/-Vaultwarden-black?style=for-the-badge&logo=bitwarden)](https://github.com/dani-garcia/vaultwarden)

| **Hypervisor**                                                                                                      | **OS**                                                                                                           | **Tools**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | **Networking**                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| [![Proxmox](https://img.shields.io/badge/-Proxmox-black?style=for-the-badge&logo=Proxmox)](https://www.proxmox.com) | [![Debian](https://img.shields.io/badge/-Debian-black?style=for-the-badge&logo=debian)](https://www.debian.org/) | [![Ansible](https://img.shields.io/badge/-Ansible-black?style=for-the-badge&logo=ansible&logoColor=red)](https://www.ansible.com/) [![Docker](https://img.shields.io/badge/-Docker-black?style=for-the-badge&logo=docker)](https://www.docker.com/) [![Kubernetes](https://img.shields.io/badge/-Kubernetes-black?style=for-the-badge&logo=kubernetes)](https://k3s.io/) <br> [![Packer](https://img.shields.io/badge/-Packer-black?style=for-the-badge&logo=packer)](https://www.packer.io/) [![Terraform](https://img.shields.io/badge/-Terraform-black?style=for-the-badge&logo=terraform)](https://developer.hashicorp.com/terraform) [![Vault](https://img.shields.io/badge/-Vault-black?style=for-the-badge&logo=vault)](https://developer.hashicorp.com/terraform) | [![TP-Link](https://img.shields.io/badge/-TP--Link-black?style=for-the-badge&logo=tp-link)](https://www.tp-link.com/) |

</div>

<details>
<summary><h2>📐 <b>Infra Diagram<b> </h2></summary>

![Architecture](.github/architecture.webp)
  
</details>

## 📖 **Overview**

This repository contains the IaC ([Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)) configuration for my homelab.

My homelab runs on **Proxmox** across three physical hosts, with VMs managed and maintained using [Terraform](https://www.terraform.io/). All VMs are provisioned from templates created with [Packer](https://www.packer.io/).

As of now, all services are **containerized** using **Docker Compose**. I plan to migrate them all to a **Kubernetes ([K3S](https://k3s.io/))** cluster for orchestration. The infrastructure is managed through **Ansible** playbooks for configuration management and automation.

All environment variables and secrets and stored in **HashiCorp's Vault**, and is hosted on an external server that is manually managed as of now. An **Ansible** playbook fetches the required environment variables and sets them in `.env` files for **Docker Compose**. Refer to `external/` for further details.

## 🛠 **Infrastructure Stack**

### **Tools & Automation**

- **[Terraform](https://www.terraform.io/)** - Infrastructure provisioning
- **[Packer](https://www.packer.io/)** - VM template creation
- **[Ansible](https://www.ansible.com/)** - Configuration management and automation
- **[Docker](https://www.docker.com/)** - Container orchestration
- **[Kubernetes (K3s)](https://k3s.io/)** - Container orchestration platform
- **[Vault](https://developer.hashicorp.com/vault)** - Environment variables and secrets management

### **Services**

| Purpose               | Service                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------- |
| Smart Home Monitoring | [HomeAssistant](https://www.home-assistant.io/)                                           |
| Backups               | [Borgmatic](https://torsion.org/borgmatic/)                                               |
| Tailscale VPN Server  | [Headscale](https://github.com/juanfont/headscale)                                        |
| Photo Management      | [Immich](https://github.com/immich-app/immich)                                            |
| Password Manager      | [Vaultwarden](https://github.com/dani-garcia/vaultwarden)                                 |
| Reverse Proxy         | [Traefik](https://traefik.io/)                                                            |
| Automation            | [n8n](https://n8n.io/)                                                                    |
| Note-taking           | [Flatnotes](https://github.com/gedulis12/flatnotes) + [Syncthing](https://syncthing.net/) |
| Document Storage      | [Paperless-ngx](https://paperless-ngx.readthedocs.io/)                                    |
| DAV Server            | [Baïkal](https://sabre.io/baikal/)                                                        |
| File Sharing          | [Balti](https://github.com/mradigen/balti)                                                |
| URL Shortener         | [Chota](https://github.com/mradigen/chota)                                                |
| Pastebin              | [Kachra](https://github.com/mradigen/kachra)                                              |

## 📁 **Repository Structure**

```
.
├── ansible/     # Ansible playbooks and configurations
├── docker/      # Docker Compose files and configurations
├── external/    # External service configurations that require uptime
├── packer/      # VM template definitions
└── terraform/   # Terraform infrastructure code
```

Each directory contains its own README with detailed information about the configurations and usage.

## 🖥️ **Hardware**

<details>
  <summary><strong>Setup</strong></summary>

![Setup](.github/setup.webp)
  
</details>

<details>
  <summary><strong>Physical Hosts</strong></summary>

| Host      | CPU               | Threads | RAM   | Storage         |
| --------- | ----------------- | ------- | ----- | --------------- |
| **Vyria** | AMD Ryzen 5 5600X | 12      | 16 GB | 480 GB NVMe     |
| **Alpha** | Intel i5-6200U    | 4       | 8 GB  | 128 GB SATA SSD |
| **Beta**  | Intel i5-7300U    | 4       | 8 GB  | 256 GB SATA SSD |

</details>

<details>
  <summary><strong>Virtual Machines</strong></summary>

### Vyria

| VM              | Cores | RAM  | Storage | Purpose          |
| --------------- | ----- | ---- | ------- | ---------------- |
| **Vyria**       | 4     | 8 GB | 260 GB  | Main services    |
| **Kubernetes1** | 2     | 2 GB | 10 GB   | K3s cluster node |

### Beta

| VM                     | Cores | RAM  | Storage | Purpose          |
| ---------------------- | ----- | ---- | ------- | ---------------- |
| **Kubernetes2 (TODO)** | 2     | 2 GB | 10 GB   | K3s cluster node |
| **Home Assistant**     | 2     | 2 GB | 32 GB   | Home automation  |

### Alpha

| VM                     | Cores | RAM  | Storage | Purpose          |
| ---------------------- | ----- | ---- | ------- | ---------------- |
| **Kubernetes3 (TODO)** | 2     | 2 GB | 10 GB   | K3s cluster node |

</details>

<details>
  <summary><strong>Networking</strong></summary>

| Device                | Purpose          | Notes                                           |
| --------------------- | ---------------- | ----------------------------------------------- |
| **ISP Router**        | Internet gateway | Default configuration                           |
| **TP Link WR840N v6** | Network access   | Access Point mode, DHCP disabled, WiFi disabled |

</details>

## 📌 **To-Do**

- [x] Readme
- [x] Setup basic o11y
- [ ] Add metrics to Proxmox
- [ ] Make Terraform and Packer fetch secrets from Vault
- [ ] Setup a CI/CD pipeline
- [ ] Migrate services to k3s

## **Credits**

- Inspired by [mafyuh](https://github.com/Mafyuh)
