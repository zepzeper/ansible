# Inventory

## Layout

```
inventory/production/
├── hosts.ini
├── group_vars/
│   ├── all/
│   │   ├── vars.yml       # Global variables
│   │   └── vault.yml      # Encrypted secrets (Ansible Vault)
│   ├── k3s_master/
│   │   └── vars.yml       # Master-specific config
│   └── k3s_worker/
│       └── vars.yml       # Worker-specific config
└── host_vars/
    ├── ds10u.yml          # Master host overrides
    └── pi.yml             # Worker host overrides
```

## Hosts.ini

```ini
[k3s_master]
ds10u ansible_host=100.117.255.24 ansible_user=zepzeper

[k3s_worker]
pi ansible_host=pi.krugten.org ansible_user=admin

[k3s:children]
k3s_master
k3s_worker
```

- **ds10u**: Connected via Tailscale IP `100.117.255.24`, user `zepzeper`
- **pi**: Connected via public hostname `pi.krugten.org`, user `admin`

## group_vars/all/vars.yml

Global defaults applied to every host:

| Variable | Value | Purpose |
|----------|-------|---------|
| `timezone` | `Europe/Amsterdam` | System timezone |
| `locale` | `en_US.UTF-8` | Default locale |
| `admin_username` | `admin` | Default admin user (overridable) |
| `base_packages` | curl, wget, git, vim, ... | Installed everywhere |
| `server_packages` | btop, iotop, tcpdump, ... | Monitoring tools |

## group_vars/all/vault.yml

Encrypted with Ansible Vault. Contains:

- `vault_tailscale_authkey` — Tailscale pre-auth key
- `vault_k3s_token` — K3s cluster join token
- `vault_cloudflare_api_token` — Cloudflare API token for DNS/certs

## group_vars/k3s_master/vars.yml

| Variable | Value |
|----------|-------|
| `k3s_role` | `server` |
| `k3s_extra_flags` | `--disable traefik --write-kubeconfig-mode 644` |
| `k3s_advertise_routes` | `192.168.1.0/24` |
| TCP ports | 6443, 10250, 10251, 10252, 53 |
| UDP ports | 8472, 53 |

## group_vars/k3s_worker/vars.yml

| Variable | Value |
|----------|-------|
| `k3s_role` | `agent` |
| TCP ports | 10250 |
| UDP ports | 8472 |

## host_vars/ds10u.yml

Overrides the global admin user to `zepzeper` (personal machine). Sets SSH keys, boot config (systemd-boot, UEFI), and disk device.

## host_vars/pi.yml

Sets Raspberry Pi SSH keys and boot config (generic-extlinux-compatible, no UEFI).

## Adding a new node

1. Run the preseed for OS install (see `preseed/` directory)
2. Add to `hosts.ini` in the appropriate group
3. Create `host_vars/<hostname>.yml` with SSH keys
4. Run `make deploy` or individual playbooks
