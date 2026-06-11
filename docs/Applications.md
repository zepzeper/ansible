# Applications

All applications run on Kubernetes as Deployments with nginx-ingress and cert-manager TLS. They are defined in `kubernetes-manifests/` and applied by the `k8s-apps` role.

## Pi-hole

| Field | Value |
|-------|-------|
| Namespace | `pihole` |
| DNS | `192.168.1.2` (LoadBalancer) |
| Web UI | `https://pihole.krugten.org` |
| Storage | hostPath `/var/lib/pihole` |

Network-wide DNS with ad blocking. All LAN devices use `192.168.1.2` as their DNS server via DHCP.

## Home Assistant

| Field | Value |
|-------|-------|
| Namespace | `home-assistant` |
| URL | `https://homeassistant.krugten.org` |
| Storage | hostPath `/var/lib/home-assistant` |

Home automation platform.

## Vaultwarden

| Field | Value |
|-------|-------|
| Namespace | `vaultwarden` |
| URL | `https://vaultwarden.krugten.org` |
| Storage | hostPath `/var/lib/vaultwarden` |

Lightweight Bitwarden-compatible password manager.

## Mealie

| Field | Value |
|-------|-------|
| Namespace | `mealie` |
| URL | `https://mealie.krugten.org` |
| Storage | 5Gi PVC |

Recipe manager.

## Uptime Kuma

| Field | Value |
|-------|-------|
| Namespace | `kuma` |
| URL | `https://kuma.krugten.org` |
| Storage | 1Gi PVC |

Uptime monitoring and status pages.

## Homepage

| Field | Value |
|-------|-------|
| Namespace | `homepage` |
| URL | `https://home.krugten.org` |
| Storage | hostPath `/var/lib/homepage` |

Dashboard with service widgets, system stats, and bookmarks.

## TuliProx

| Field | Value |
|-------|-------|
| Namespace | `tuliprox` |
| URL | `https://iptv.krugten.org` |
| Storage | hostPath + 2Gi/1Gi PVCs |

IPTV proxy with channel filtering (NL/EN/Adult).

## Calibre

| Field | Value |
|-------|-------|
| Namespace | `books` |
| URL | `https://calibre.krugten.org` |
| Storage | 50Gi PVC |

E-book library management.

## Media stack (qBittorrent / Prowlarr / Readarr)

| App | Namespace | URL | Storage |
|-----|-----------|-----|---------|
| qBittorrent | media | `https://qbittorrent.krugten.org` | 1Gi config + 100Gi downloads |
| Prowlarr | media | `https://prowlarr.krugten.org` | 1Gi PVC |
| Readarr | media | `https://readarr.krugten.org` | 1Gi PVC (shares downloads) |

Media automation stack (arr suite).

## Paperless

| Field | Value |
|-------|-------|
| Namespace | `paperless` |
| URL | `https://paperless.krugten.org` |
| Stack | Paperless + PostgreSQL + Redis |
| Storage | 10Gi (paperless) + 5Gi (postgres) PVCs |

Document management system with OCR and tagging.

## Factorio (disabled)

Factorio server is defined but commented out in the manifests task. If re-enabled, it uses LoadBalancer on UDP 34197 with IP `192.168.1.2` (currently claimed by Pi-hole — needs a different IP).
