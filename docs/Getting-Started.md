# Getting Started

## Prerequisites

- Python 3.12+ with pip
- SSH access to all target hosts
- Ansible Vault password (see [Secrets](Secrets))

## Control node setup

```bash
# Create a virtual environment
python3 -m venv ~/ansible-env
source ~/ansible-env/bin/activate

# Install Ansible and dependencies
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
```

### Vault password

The Ansible Vault protects secrets (Cloudflare API token, Tailscale auth key, K3s token). Provide it via:

```bash
# Option 1: env var (takes precedence)
export ANSIBLE_VAULT_PASSWORD="your-password-here"

# Option 2: password file
mkdir -p ~/.config/ansible
echo "your-password-here" > ~/.config/ansible/krugten-vault-password
chmod 600 ~/.config/ansible/krugten-vault-password
```

The script `scripts/get-vault-password.sh` reads from either source automatically.

## Running playbooks

Use the Makefile for common operations:

```bash
make deploy          # Full sequence (bootstrap → k3s → manifests → backup)
make bootstrap       # System config (common + server roles)
make k3s             # Tailscale + K3s install
make manifests       # K8s infrastructure + applications
make base            # K8s infra only (cert-manager, nginx, MetalLB, etc.)
make apps            # K8s applications only
make backup          # Set up restic backups
make backup-run      # Trigger immediate backup
make lint            # Run ansible-lint
make syntax-check    # Validate all playbook syntax
make ping            # Test connectivity to all hosts
```

Or run playbooks directly:

```bash
ansible-playbook playbooks/k3s-manifests.yml
ansible-playbook playbooks/bootstrap.yml --tags firewall
```

### Tags

Selective runs using tags:

| Tag | Scope |
|-----|-------|
| `bootstrap` | Base system config (hostname, packages, timezone) |
| `ssh` | SSH hardening |
| `users` | Admin user + SSH keys |
| `firewall` | iptables rules |
| `sysctl` | Kernel tuning |
| `system` | Swap, journald, unattended-upgrades |
| `networking` | Tailscale |
| `k3s` / `kubernetes` | K3s installation |
| `k8s` | K8s infrastructure manifests |
| `apps` | Application manifests |
| `backup` | Restic backup setup |

```bash
make tag TAG=firewall         # Only firewall tasks across all plays
ansible-playbook playbooks/bootstrap.yml --tags ssh  # Only SSH hardening
```
