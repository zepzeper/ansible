# monitoring

Periodic assertions about the host, and one shared notifier for failed units.

## Worth knowing

Every check here covers a failure that produces **no symptom** until it is
expensive: a backup that silently stops, a certificate whose renewal is failing
while its Ready condition still says True, a disk filling toward the point where
writes fail.

Uptime Kuma already checks HTTP endpoints. None of these conditions make a
website stop responding, which is precisely why the backup could fail nightly
for weeks unnoticed.

`alert@.service` is a template unit: any service declares
`OnFailure=alert@%n.service` and the instance name carries which unit failed.
One notifier for the whole host rather than one per job.

Variables are declared and validated in `meta/argument_specs.yml`.
