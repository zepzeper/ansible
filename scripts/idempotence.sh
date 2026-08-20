#!/usr/bin/env bash
# Converge staging twice and fail if the second run reports any change.
#
# This is the check the repo most needed and did not have. A task that is not
# idempotent reports changed forever, which means a real change is
# indistinguishable from noise in the recap - and it is how a silently
# destructive task (a template clobbering another role's file, a handler
# restarting a service every run) hides in plain sight.

set -euo pipefail

ANSIBLE_PLAYBOOK="${ANSIBLE_PLAYBOOK:-$HOME/ansible-env/bin/ansible-playbook}"
INVENTORY="${INVENTORY:-inventories/staging/hosts.yml}"
PLAYBOOK="${PLAYBOOK:-playbooks/bootstrap.yml}"

./scripts/staging-container.sh up

echo "==> first converge"
"$ANSIBLE_PLAYBOOK" -i "$INVENTORY" "$PLAYBOOK"

echo
echo "==> second converge (must report changed=0)"
out="$("$ANSIBLE_PLAYBOOK" -i "$INVENTORY" "$PLAYBOOK" | tee /dev/stderr)"

# The recap line is the authority: parsing per-task output misses handlers.
changed="$(printf '%s' "$out" | sed -n 's/.*changed=\([0-9]*\).*/\1/p' | tail -1)"

if [ -z "$changed" ]; then
    echo "could not parse a PLAY RECAP from the second run" >&2
    exit 1
fi

if [ "$changed" != "0" ]; then
    echo >&2
    echo "NOT IDEMPOTENT: second converge reported changed=$changed" >&2
    echo "Re-run with -v and look for tasks reporting changed on an unchanged host." >&2
    exit 1
fi

echo
echo "idempotent: second converge reported changed=0"
