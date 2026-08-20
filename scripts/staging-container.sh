#!/usr/bin/env bash
# Lifecycle for the throwaway staging container.
#
# geerlingguy/docker-debian12-ansible is used rather than plain debian:12 because
# the roles need a working systemd - systemctl is-active, enable, and the handler
# restarts all no-op or fail without PID 1 being systemd. That image is built for
# exactly this and keeps the CI job to a few lines.

set -euo pipefail

NAME="${STAGING_CONTAINER:-ds10u-staging}"
IMAGE="${STAGING_IMAGE:-geerlingguy/docker-debian12-ansible:latest}"

case "${1:-}" in
    up)
        if [ -n "$(docker ps -q -f "name=^${NAME}$")" ]; then
            echo "already running: $NAME"
            exit 0
        fi
        docker rm -f "$NAME" >/dev/null 2>&1 || true
        # --privileged and the cgroup mount are what let systemd run as PID 1;
        # without them every systemd module call fails with "System has not been
        # booted with systemd".
        docker run -d --name "$NAME" \
            --privileged \
            --cgroupns=host \
            -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
            "$IMAGE" /lib/systemd/systemd >/dev/null
        for _ in $(seq 1 30); do
            if docker exec "$NAME" systemctl is-system-running 2>/dev/null | grep -qE 'running|degraded'; then
                echo "up: $NAME"
                exit 0
            fi
            sleep 1
        done
        echo "systemd did not come up in $NAME" >&2
        docker logs "$NAME" >&2 || true
        exit 1
        ;;
    down)
        docker rm -f "$NAME" >/dev/null 2>&1 || true
        echo "removed: $NAME"
        ;;
    *)
        echo "usage: $0 {up|down}" >&2
        exit 1
        ;;
esac
