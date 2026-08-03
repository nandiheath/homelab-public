# HLP-007 — Controller network bootstrap

- Status: running
- Owner: Main
- Depends on: HLP-001, HLP-005, HL-003

## Owned paths

- `ansible/playbooks/bootstrap_network.yaml`
- `argocd/infrastructure/infrastructure-app-of-apps/apps/cilium.yaml`
- `tasks/planned/HLP-007-controller-network-bootstrap.md`

## Goal

Apply the private rendered Cilium manifest from the controller and preserve that source under Argo CD.

## Implementation

Use only pinned controller `bin/kubectl`, exported mode-0600 kubeconfig, and the private Cilium artifact. Validate exactly five `KUBERNETES_SERVICE_HOST` values equal the private API endpoint, no documentation endpoint remains, and all other fields match public source. Apply from the controller and wait for Cilium, API, and all nodes. Configure the Cilium Application for `homelab-private` and private production source.

## Acceptance criteria

- No rendered artifact or source with `192.0.2.11` can be applied to production.
- Cilium application reconciliation retains the private artifact source.
- Controller-only execution never copies the rendered artifact to a Pi.

## Verification

- Local fixture validation for endpoint drift and sentineled delegated apply.

## Blockers

- HLP-001, HLP-005, and HL-003 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
