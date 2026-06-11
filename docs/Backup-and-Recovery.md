# Backup and Recovery

Backups are managed by [restic](https://restic.net/) with a systemd timer running daily at 02:00.

## What gets backed up

| Path | App |
|------|-----|
| `/var/lib/pihole` | Pi-hole config + lists |
| `/var/lib/home-assistant` | Home Assistant config |
| `/var/lib/vaultwarden` | Vaultwarden data |
| `/var/lib/homepage` | Homepage dashboard config |
| `/var/lib/tuliprox/config` | TuliProx config |
| `/run/secrets/rendered` | Rendered secrets |

## Retention policy

| Policy | Count |
|--------|-------|
| Keep last | 7 |
| Keep daily | 30 |
| Keep weekly | 12 |
| Keep monthly | 6 |
| Auto-prune | Yes |

## Configuring the backup destination

Set in `group_vars/all/vars.yml` or hosts vars:

```yaml
restic_repo: /var/backups/restic           # Local path
# restic_repo: s3:https://s3.eu-central-1.amazonaws.com/bucket-name
# restic_repo: b2:my-bucket-name
# restic_repo: rclone:remote:path
```

And the password in `vault.yml`:

```yaml
restic_password: "your-restic-repo-password"
```

## Running on demand

```bash
make backup          # Install/configure backup system
make backup-run      # Trigger immediate backup
```

Or SSH into the host:

```bash
sudo systemctl start restic-backup.service
sudo journalctl -u restic-backup.service   # Check results
```

## Restoring from backup

```bash
# List snapshots
restic -r /var/backups/restic snapshots

# Restore latest snapshot to a temp directory
restic -r /var/backups/restic restore latest --target /tmp/restore

# Restore a specific path from latest
restic -r /var/backups/restic restore latest \
  --path /var/lib/home-assistant --target /tmp/restore

# Restore a specific snapshot
restic -r /var/backups/restic restore <snapshot-id> --target /tmp/restore
```

For Kubernetes PVC-based apps (Mealie, Calibre, Paperless, etc.), back up and restore via:
```bash
kubectl cp <namespace>/<pod>:/data /tmp/backup
```
