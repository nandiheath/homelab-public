# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Depends on: HLP-004

## Owned paths

- `ansible/playbooks/reset.yaml`
- `ansible/roles/k3s_reset/tasks/preflight.yml`
- `ansible/roles/k3s_reset/tasks/capture_host_facts.yml`
- `ansible/roles/k3s_reset/tasks/assert_absence.yml`
- `ansible/roles/k3s_reset/defaults/main.yml`
- `ansible/roles/cluster_health/tasks/main.yml`
- `tests/ansible_lifecycle/run-entrypoints.sh`
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
- Live reset, install, cluster, router, and remote-host operations require explicit current-session authorization; the reset authorization was supplied for this attempt.

## Blockers

- The entire non-mutating reset preflight now passes against all three live nodes and stops at the final exact-confirmation guard. Destructive reset, kernel activation, clean install, network bootstrap, and GitOps bootstrap still require fresh exact current-session confirmations.

## Completion handoff

- Summary: Completed and live-verified the guarded non-mutating reset preflight. Delegated host checks now use inventory SSH connections, live user identity is compared by host, and embedded-etcd health is read from each server's local metrics endpoint instead of requiring an unshipped `etcdctl`.
- Files changed: `ansible/roles/k3s_reset/defaults/main.yml`; `ansible/roles/k3s_reset/tasks/preflight.yml`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private `ansible/inventory/production/hosts.yml`.
- Observed verification: Reset syntax and lifecycle entrypoint fixtures passed. The full live reset preflight captured all three preservation baselines, revalidated hostname/user/network identity on every host, observed three unique healthy `v3.5.21` etcd members with one leader and two active peers each, captured API/Application/PVC facts, passed every operation-guard check, and rejected the deliberately wrong confirmation at the final direct-literal gate; no reset mutation task ran. `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, the public/private repository graph check, private inventory parsing, and private `make validate` all passed; manifest validation reported `352` resources, `245` valid, `0` invalid, `0` errors, and `107` skipped.
- Follow-ups: Supply a fresh exact reset confirmation and run only reset with `--ask-become-pass`. Kernel activation, install, network bootstrap, and GitOps phases remain separately gated and must each complete every acceptance check before HLP-005 can close.
