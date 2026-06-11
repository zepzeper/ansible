# Roles

## `common` — Base system config

| Task | Tags | Detail |
|------|------|--------|
| Set hostname | `bootstrap` | `hostname` module |
| Update /etc/hosts | `bootstrap` | `127.0.1.1` entry |
| Set timezone | `bootstrap` | From `timezone` var (Europe/Amsterdam) |
| Generate locales | `bootstrap` | `en_US.UTF-8` + extra locales |
| Install base packages | `bootstrap` | curl, wget, git, vim, sudo, etc. |
| Create admin user | `users` | Configurable via `admin_username`/`admin_group` |
| Set authorized SSH keys | `users` | Per-host keys via `admin_ssh_keys` |
| Configure sudo NOPASSWD | `users` | `%admin ALL=(ALL) NOPASSWD:ALL` |
| Disable root SSH login | `ssh` | `PermitRootLogin no` |

**Variables:** `server_hostname`, `timezone`, `locale`, `admin_username`, `admin_group`, `admin_ssh_keys`, `base_packages`

---

## `server` — Hardening and tuning

| Task | Tags | Detail |
|------|------|--------|
| Install server packages | `bootstrap` | btop, iotop, tcpdump, etc. |
| SSH hardening (3 tasks) | `ssh` | No password, pubkey only, no challenge-response |
| iptables setup | `firewall` | Install, deploy rules, enable persistence |
| sysctl tuning | `sysctl` | `net.ipv4.ip_forward=1`, `bridge-nf-call-*`, `swappiness=10` |
| Load br_netfilter | `sysctl` | Required for K8s networking |
| Disable swap | `system` | `swapoff -a` + remove from fstab (kubelet requirement) |
| Journald limits | `system` | `SystemMaxUse=500M`, `MaxFileSec=7d` |
| Unattended-upgrades | `system` | Security-only updates, auto-cleanup |
| Disable bluetooth/pipewire | `bootstrap` | No need on servers |

---

## `tailscale` — Wireguard VPN

| Task | Tags | Detail |
|------|------|--------|
| Add apt repo | `networking` | Official Tailscale repo via `deb822_repository` |
| Install package | `networking` | `apt install tailscale` |
| Enable service | `networking` | `systemctl enable --now tailscaled` |
| Authenticate | `networking` | `tailscale up` with auth key, advertises LAN routes |

**Variables:** `vault_tailscale_authkey`, `k3s_advertise_routes`

---

## `k3s` — Kubernetes cluster

Includes `master.yml` (when `k3s_role == "server"`) or `worker.yml` (when `k3s_role == "agent"`).

| Task | Tags | Detail |
|------|------|--------|
| Install dependencies | `k3s` | curl, iptables, conntrack |
| Download install script | `k3s` | `get.k3s.io` |
| Install k3s | `k3s` | Server or agent with version pinning |
| Open firewall ports | `k3s`, `firewall` | Per-role port lists via `ansible.posix.iptables` |
| Copy kubeconfig | `k3s` | Master only — to admin user's `~/.kube/config` |

**Variables:** `k3s_role`, `k3s_version`, `k3s_extra_flags`, `k3s_master_tcp_ports`, `k3s_master_udp_ports`, `k3s_worker_tcp_ports`, `k3s_worker_udp_ports`, `vault_k3s_token`

---

## `k8s-base` — Kubernetes infrastructure

| Task | Tags | Detail |
|------|------|--------|
| Fix kubeconfig perms | `k8s` | `chmod 0644 /etc/rancher/k3s/k3s.yaml` |
| Copy manifests | `k8s`, `manifests` | Rsyncs `kubernetes-manifests/` to target |
| Create hostPath dirs | `k8s`, `storage` | `/var/lib/pihole`, etc. |
| Create namespaces | `k8s`, `namespaces` | 12 namespaces via `kubectl create ns` |
| Apply cert-manager | `k8s`, `cert-manager` | Official manifest + wait for ready |
| Create Cloudflare secrets | `k8s`, `secrets` | API token injected into 11 namespaces |
| Apply ClusterIssuer | `k8s`, `cert-manager` | Let's Encrypt prod with Cloudflare DNS01 |
| Apply nginx-ingress | `k8s`, `ingress` | Official manifest + wait |
| Apply MetalLB | `k8s`, `metallb` | Native manifest + IPPool + wait |
| Apply external-dns | `k8s`, `dns` | Cloudflare-synced DNS |

---

## `k8s-apps` — Application layer

| Task | Tags | Detail |
|------|------|--------|
| Home Assistant config | `apps`, `home-assistant` | Template `configuration.yaml` |
| Homepage config | `apps`, `homepage` | 5 template files (settings, services, etc.) |
| TuliProx config | `apps`, `tuliprox` | 3 template files |
| Apply all manifests | `apps`, `manifests` | 12 Kubernetes manifests via `kubectl apply` |
| Health checks | `apps`, `health` | Wait for all deployments to be Available |

---

## `backup` — Restic backup

| Task | Tags | Detail |
|------|------|--------|
| Install restic | `backup` | `apt install restic` |
| Init repo | `backup` | `restic init` if not already initialized |
| Deploy backup script | `backup` | Template that backs up all hostPath dirs |
| Deploy systemd units | `backup` | Service + timer |
| Enable timer | `backup` | Runs daily at 02:00 |

**Variables:** `restic_repo`, `restic_password`, `backup_paths`, `restic_retention`
