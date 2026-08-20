# baseline

Machine identity, admin users, locale, base packages.

Deliberately policy-free. Hardening, firewall and DNS are separate roles so each can be applied and tested alone.

## Worth knowing

`base_packages` must include `locales` and `openssh-server` — the locale tasks here and the SSH tasks in `hardening` both depend on files those packages provide. Both were missing until a staging converge failed on them; ds10u only worked because its preseed happened to install them.

Variables are declared and validated in `meta/argument_specs.yml`; a missing or mistyped one fails before any task runs.
