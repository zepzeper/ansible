# Backlog

Work that was considered, deliberately deferred, and why. Each entry records the
trigger that should make it worth doing — so the decision gets revisited on
evidence rather than on a vague sense that it is overdue.

## Deferred

### Molecule tests for the roles

Per-role test scenarios, run in CI across a Debian version matrix.

**Why deferred.** The staging container plus the idempotence job already cover
most of what Molecule would catch. Converging `bootstrap.yml` against a clean
container exercises `baseline`, `hardening`, `firewall` and `resolver` end to
end, and the second-run `changed=0` assertion catches non-idempotent tasks —
which is the bulk of what per-role tests find. Molecule would add isolation
between roles and a version matrix, not fundamentally new coverage.

**Revisit when** a second host with a different Debian release joins, or a role
gains logic that cannot be reached through `bootstrap.yml` — `k3s`, `tailscale`
and the cluster roles are all currently untested for exactly that reason.

### Automated dependency bumps

Something like Renovate raising pull requests for pinned versions.

**Why deferred.** Needs a decision about how updates should reach you, which is
a workflow question rather than a technical one.

**Revisit soon — this one rots.** Every container image is pinned by digest and
`k3s_version` is pinned to a release. Those pins are correct today and become
stale silently: nothing in the repo will tell you a pinned image has a published
CVE fix. The pinning was the right call, but it converts a silent-change problem
into a silent-staleness problem, and only a bump tool closes that.

### Ingress source-range allowlist

`whitelist-source-range` on the ingress-nginx ConfigMap, limited to the LAN,
the tailnet, and the pod CIDR.

**Why deferred.** It is a backstop against future misconfiguration, not a fix
for present exposure. Services are unreachable from the internet today because
every published address is unroutable there — public DNS resolves to
`100.64.0.0/10` (CGNAT), and the only thing answering on the WAN address is the
router's own management interface.

**Revisit when** a port-forward is added for any reason, or when the ingress
becomes reachable from outside by any path. At that point the allowlist stops
being belt-and-braces and becomes the actual control.

**Note the sizing constraint.** Traffic arriving on the tailnet address is SNAT'd
to the pod-network gateway, because `externalTrafficPolicy: Local` preserves
source IPs for the MetalLB VIP path but not for `externalIPs`. An allowlist of
just `192.168.1.0/24,100.64.0.0/10` would therefore return 403 to every tailnet
client. The pod CIDR has to be included, which is safe: that path is already
gated by tailnet membership before nginx sees the request.

## Blocked on hardware

Expected around November 2026, when a NAS and a second server arrive.

- **Off-host backup.** `restic_repo` still points at `/var/backups/restic`, on
  the same `/dev/sda2` as the data it protects. The role warns on every run.
  Restic takes `sftp:`, `s3:`, `b2:` and `rest:` URLs with no other change.
- **Shared storage.** Every PVC uses `local-path`, which is node-bound. That is
  the specific thing blocking a second node from being useful rather than
  decorative — NFS from the NAS, or Longhorn, is the prerequisite.
- **Real replication.** A second k3s node only buys availability once storage
  and ingress are not both single points of failure.

## Known circular dependency

Vaultwarden runs on ds10u and holds the passphrase for `dev-secrets`, which
holds the Ansible vault password, which holds the restic repository password.

If ds10u is lost, that chain cannot be walked: the credential needed to open the
backups lives on the machine the backups exist to restore.

The mitigation is one entry somewhere outside that chain — a phone note, paper,
or a hosted password manager. It is not a system to build, and it is the single
highest-value item on this page.
