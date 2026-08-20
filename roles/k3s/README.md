# k3s

Installs and reconciles a k3s server or agent.

Opens no ports. It surfaces what it needs as `firewall_tcp_ports` / `firewall_udp_ports` and lets `firewall` render them.

## Worth knowing

The install task is a no-op once `/usr/local/bin/k3s` exists, so a changed `k3s_extra_flags` would never reach an existing host. The role compares the flags against the systemd unit and re-runs the installer on drift.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
