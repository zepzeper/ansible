# hardening

SSH hardening, sysctl, swap, journald, unattended upgrades.

Host policy independent of what the machine goes on to run.

## Worth knowing

`manage_swap` and `manage_kernel_modules` default true and are turned off by the staging inventory — a container shares the host kernel, so it has no swap of its own and cannot load modules.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
