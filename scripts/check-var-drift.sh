#!/usr/bin/env bash
# Flag inventory variables that restate a role default, or that redefine a list
# the role already owns.
#
# prod's group_vars carried its own base_packages, and that copy had lost
# openssh-server. Because group_vars outranks role defaults, the role's correct
# list was masked and the SSH hardening tasks edited a file that did not exist.
# Nothing failed loudly; the host simply came up wrong.

set -euo pipefail

PY="${PY:-$HOME/ansible-env/bin/python}"

"$PY" - <<'PYEOF'
import sys, yaml, pathlib, collections

def load(p):
    try:
        d = yaml.safe_load(p.read_text()) or {}
        return d if isinstance(d, dict) else {}
    except Exception:
        return {}

defaults = {}
for f in sorted(pathlib.Path("roles").glob("*/defaults/main.yml")):
    for k, v in load(f).items():
        defaults.setdefault(k, []).append((str(f), v))

problems = []
for f in sorted(pathlib.Path("inventories").glob("*/**/*.yml")):
    if "vault.yml" in str(f):
        continue
    for k, v in load(f).items():
        if k not in defaults:
            continue
        for df, dv in defaults[k]:
            if v == dv:
                problems.append(("restates", k, str(f), df))
            elif isinstance(dv, list) and isinstance(v, list) and set(dv) - set(v):
                missing = ", ".join(sorted(set(dv) - set(v)))
                problems.append((f"drops [{missing}] from", k, str(f), df))

for kind, k, f, df in problems:
    print(f"  {f}", file=sys.stderr)
    print(f"    {k} {kind} the default in {df}", file=sys.stderr)

if problems:
    print(file=sys.stderr)
    print("An inventory value that merely restates a role default is a second", file=sys.stderr)
    print("place to edit. One that drops entries silently masks them.", file=sys.stderr)
    sys.exit(1)

print("  no inventory variable restates or truncates a role default")
PYEOF
