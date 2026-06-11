# Secrets

## Ansible Vault

All secrets are stored in `inventory/production/group_vars/all/vault.yml`, encrypted with Ansible Vault.

### Current secrets

| Variable | Used in | Purpose |
|----------|---------|---------|
| `vault_tailscale_authkey` | `tailscale` role | Tailscale node authentication |
| `vault_k3s_token` | `k3s` role | K3s cluster join token |
| `vault_cloudflare_api_token` | `k8s-base` role | cert-manager DNS01 + ExternalDNS |

### Editing secrets

```bash
ansible-vault edit inventory/production/group_vars/all/vault.yml
```

### Adding a new secret

```bash
ansible-vault encrypt_string "your-secret-value" --name "vault_new_secret" >> inventory/production/group_vars/all/vault.yml
```

Reference it in a template or task as `{{ vault_new_secret }}`.

## Vault password

The vault password is never stored in the repository. Provide it via one of:

```bash
# Option 1: Environment variable (takes precedence)
export ANSIBLE_VAULT_PASSWORD="your-password-here"

# Option 2: Password file outside the repo
mkdir -p ~/.config/ansible
echo "your-password-here" > ~/.config/ansible/krugten-vault-password
chmod 600 ~/.config/ansible/krugten-vault-password
```

The script `scripts/get-vault-password.sh` handles both methods and is configured in `ansible.cfg`.

## Kubernetes secrets

The Cloudflare API token is also injected into Kubernetes as secrets in 11 namespaces via the `k8s-base` role:

```bash
kubectl create secret generic cloudflare-api-token \
  --namespace=<ns> \
  --from-literal=api-token={{ vault_cloudflare_api_token }}
```

Applications that consume these secrets:
- **cert-manager**: ClusterIssuer DNS01 challenge
- **external-dns**: Cloudflare API for DNS record sync
- **home-assistant**, **pihole**, **tuliprox**, etc.: For their own Cloudflare integrations

## Best practices

- Never commit `.vault_password` — it's in `.gitignore`
- Never echo secrets in Ansible output (avoid `no_log: false` on sensitive tasks)
- Rotate Tailscale auth keys periodically
- If a secret is exposed, revoke it immediately and re-encrypt `vault.yml`
