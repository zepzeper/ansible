# firewall

The only role that writes iptables.

Renders and persists the entire filter table from one template. Other roles open ports by contributing to `firewall_tcp_ports` / `firewall_udp_ports`, never by adding rules.

## Worth knowing

This exists because two writers previously fought over one file: `k3s` appended its ports and persisted them with `iptables-save`, and the next run of the templating role overwrote the result — closing port 6443 with a green PLAY RECAP. The restore handler also restarts `tailscaled`, because `iptables-restore` replaces the whole filter table and deletes the `ts-input` / `ts-forward` chains, stranding the node on the tailnet while it still answers on the LAN.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
