# Playbooks

## `bootstrap.yml`

Initial server setup. Runs on **all hosts**.

```
common role: hostname, timezone, locales, packages, admin user, SSH keys, sudo
server role: SSH hardening, iptables, sysctl tuning, swap disable, journald, unattended-upgrades
```

## `k3s.yml`

Install Tailscale and K3s. Runs on **k3s group**.

```
tailscale role: apt repo, install, authenticate, enable service
k3s role:      install server (master) or agent (worker), open firewall ports
```

## `k3s-manifests.yml`

Deploy everything to Kubernetes. Runs on **k3s_master** only.

```
k8s-base role: kubeconfig, namespaces, cert-manager, nginx-ingress, MetalLB, external-dns, Cloudflare secrets
k8s-apps role: Home Assistant config, Homepage config, TuliProx config, apply all app manifests
```

## `backup.yml`

Install and configure restic backup. Runs on **all hosts**.

```
backup role: install restic, init repo, deploy backup script, systemd timer
```

## `deploy-all.yml`

Orchestrator that runs all playbooks in sequence:

```bash
make deploy
```

Equivalent to:

```bash
make bootstrap   # 1. System config
make k3s         # 2. Tailscale + K3s
make manifests   # 3. K8s manifests
make backup      # 4. Backup setup
```

## Running selectively

```bash
make bootstrap                   # System config only
make k3s                         # Tailscale + K3s only
make manifests                   # K8s manifests only
make base                        # K8s infrastructure only
make apps                        # K8s apps only
make backup                      # Backup setup only
```

## Dry run

```bash
ansible-playbook playbooks/bootstrap.yml --check --diff
```
