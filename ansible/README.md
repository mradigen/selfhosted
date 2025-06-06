# Ansible

## Structure

```sh
ansible/
├── ansible.cfg
├── inventory.ini                       # Inventory data, example in inventory.ini.example
├── inventory.ini.example
├── playbooks
│   ├── docker.yml                      # Fetching, and updating docker-compose using env vars in Vault
│   └── tasks
│       └── docker-env-vars.yml         # The actual task of fetching and updating, cause ansible can't `loop` over `block`
└── setup                               # Playbooks used to setup the nodes
    ├── Kubernetes1.yml                 # k3s first node
    ├── Minecraft.yml                   # Minecraft node
    ├── Vyria.yml                       # Main docker node
    └── tasks                           # Common tasks used by the setup playbooks above
        ├── docker.yml
        ├── firewalld.yml
        ├── k3s.yml
        ├── tailscale.yml
        ├── user.yml
        └── utils.yml
```

## TODO

- [ ] Playbook to update and upgrade all nodes
