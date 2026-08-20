#!/usr/bin/env bash
# Assert that every tag the Makefile filters on actually selects tasks.
#
# `make base` and `make apps` filtered on --tags k8s-base and k8s-apps, neither
# of which existed anywhere in the repo. Both ran zero tasks and exited 0, so the
# failure was invisible for as long as nobody checked the cluster by hand.

set -euo pipefail

ANSIBLE_PLAYBOOK="${ANSIBLE_PLAYBOOK:-ansible-playbook}"

rc=0

# Pull every "--tags X" the Makefile actually invokes, rather than maintaining a
# second list here that could drift from it.
while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    n="$("$ANSIBLE_PLAYBOOK" playbooks/deploy-all.yml --tags "$tag" --list-tasks 2>/dev/null |
        grep -c 'TAGS:' || true)"
    if [ "$n" -eq 0 ]; then
        printf '  %-14s selects 0 tasks\n' "$tag" >&2
        rc=1
    else
        printf '  %-14s selects %s tasks\n' "$tag" "$n"
    fi
done < <(grep -oE -- '--tags [a-z0-9_-]+' Makefile | awk '{print $2}' | sort -u)

if [ "$rc" -ne 0 ]; then
    echo >&2
    echo "A Makefile target filters on a tag no task carries." >&2
    echo "It would run nothing and exit 0." >&2
fi

exit "$rc"
