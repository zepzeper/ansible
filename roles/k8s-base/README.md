# k8s-base

Cluster infrastructure applied with kubectl.

Scheduled for removal in phase 04, when Flux takes over reconciliation.

## Worth knowing

Ordering here is a fixed task sequence, which is why MetalLB-after-ingress and patch-after-apply conflicts were possible. A reconciler does not have that failure shape.

## Prerequisites

Two, both new relative to the kubectl shell-outs this replaced:

- **On the target**: `python3-kubernetes`, installed by the first task in this
  role. `kubernetes.core.k8s` runs on the host and talks to the API directly.
- **On the control node**: `kustomize` or `kubectl`, because the
  `kubernetes.core.kustomize` lookup renders `k8s/` locally before the module
  ever sees it. `dev-env ansible` installs it.
