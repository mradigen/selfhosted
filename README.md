# Self-Hosted Infrastructure as Code

This repository contains the configuration and code for my self-hosted services, managed using Infrastructure as Code principles.

| Purpose              | Service                                                |
| -------------------- | ------------------------------------------------------ |
| DAV Server           | [Baïkal](https://sabre.io/baikal/)                     |
| File Sharing         | [Balti](https://github.com/mradigen/balti)             |
| Password Manager     | [Bitwarden](https://bitwarden.com/)                    |
| Backups              | [Borgmatic](https://torsion.org/borgmatic/)            |
| URL Shortener        | [Chota](https://github.com/mradigen/chota)             |
| Tailscale VPN Server | [Headscale](https://github.com/juanfont/headscale)     |
| Photo Management     | [Immich](https://github.com/immich-app/immich)         |
| Pastebin             | [Kachra](https://github.com/mradigen/kachra)           |
| Document Storage     | [Paperless-ngx](https://paperless-ngx.readthedocs.io/) |
| Reverse Proxy        | [Traefik](https://traefik.io/)                         |

## TODO

- [ ] HashiCorp Vault for secrets management
- [ ] Make all environment variables forcefully required (so that Docker fails if they are empty)
- [ ] Ansible playbook instead of `update.sh`
- [ ] Migrate firewall config as well
- [ ] Automate using Github Actions, ArgoCD, or n8n

For any questions or issues, feel free to open an issue in this repository.
