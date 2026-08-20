# resolver

Points the host at a chosen DNS resolver.

Detects the owner of `/etc/resolv.conf` from the file's own generator line, not from a systemd unit name — dhcpcd ships as `dhcpcd.service` on some releases and `dhcpcd5.service` on others, and guessing wrong made the whole role skip silently.

## Worth knowing

`resolver_fallback` must be a resolver that actually answers. Pointing it at a device that only relays DHCP leaves no working fallback, which turns a restart of the primary into a deadlock — the node cannot resolve the registry to pull the image the primary needs to come back.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
