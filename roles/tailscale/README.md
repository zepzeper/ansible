# tailscale

Install, login, and reconcile advertised routes.

Login only runs on a node not yet on the tailnet. Routes and the exit-node flag are reconciled separately with `tailscale set`, because `tailscale up` is skipped on an existing node and a changed flag would otherwise never reach it.

## Worth knowing

`tailscale_accept_routes` defaults **false** deliberately. Tailscale installs accepted subnets in policy table 52 at rule priority 5270 — ahead of the main table — so a host physically on an advertised subnet sends its own LAN traffic into the tunnel and loses local connectivity. Reach home over the exit node instead.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
