# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Depends on: HLP-004

## Owned paths

- `docs/operations-runbook.md`
- `skills/k3s-lifecycle/SKILL.md`
- `tasks/running/HLP-005-clean-cluster-rebuild.md`

## Goal

Define the guarded backup-free reset and direct latest-minor K3s rebuild while preserving host identity and enforcing explicit authorization at every mutating phase.

## Implementation

Update the operator runbook and lifecycle skill for the direct `v1.36.2+k3s1` install with embedded etcd `v3.6.12-k3s1`, pinned Raspberry Pi kernel activation, private Cilium v1.20.0 bootstrap, and controller-only GitOps bootstrap. Require recovery readiness, independently verified host keys, exact repository/tool/version handoff, current cluster health, no backup contract, and a fresh exact confirmation for reset, kernel, install, network, and GitOps phases.

## Acceptance criteria

- Preflight records physical/serial recovery readiness, strict verified SSH pins, exact public/private revisions, controller tool versions, cluster identity, three healthy voting etcd members, API/Cilium health, and Application/PVC state before mutation.
- Every mutating phase requires its own exact current-session confirmation; missing, boolean, stale, wrong-version, wrong-source, wrong-target, or wrong-text inputs stop before mutation.
- Reset preserves Ubuntu, SSH configuration and keys, hostname, users, networking, boot firmware, and retained fallback kernel while removing Kubernetes-owned state without backup inputs.
- Kernel activation is serial, exact-package, cluster-absent, and verifies node return, pinned kernel, fallback, boot files, and K3s absence.
- Direct clean install forms exactly three healthy voting embedded-etcd members at `v1.36.2+k3s1` / `v3.6.12-k3s1`; private Cilium and controller-only GitOps complete in order without premature Applications/PVCs.
- Final acceptance proves node/API/Cilium health, expected GitOps health, exactly five Bound PVCs, empty smoke tests, no token/credential residue, and no backup policy.

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`
- `source ./bin/activate-hermit && ./scripts/validate.sh`
- No live reset, install, cluster, router, or remote host operation is authorized by this task.

## Blockers

- None for offline documentation work. Live execution remains blocked on verified production SSH host-key pins and explicit current-session authorization.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
