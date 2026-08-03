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

- Reset acceptance is complete. The next live phase is the clean K3s install; it requires its own fresh exact current-session confirmation before any mutation.

## Completion handoff

- Summary: Completed the guarded backup-free reset and its interrupted-reset recovery. The recovery selector is boolean-only and may bypass the live-cluster preflight only after every server proves the K3s binary, generated uninstall entrypoints, and primary K3s state directory are already absent.
- Files changed: `ansible/playbooks/reset.yaml`; `ansible/roles/k3s_reset/defaults/main.yml`; `ansible/roles/k3s_reset/tasks/preflight.yml`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private `ansible/inventory/production/hosts.yml`.
- Observed verification: The normal preflight captured all three preservation baselines, revalidated hostname/user/network identity, observed three unique healthy `v3.5.21` etcd voters with one leader and two peers each, captured API/Application/PVC facts, and passed every operation guard. All three generated uninstall entrypoints then ran; their Cilium state temporarily prevented SSH and the user power-cycled the nodes. After reboot, direct scans matched every pinned ECDSA host key exactly and SSH returned with the same hostnames and addresses. The guarded recovery removed the remaining exact K3s/Cilium/Longhorn paths and passed every post-reset service, process, path, user, SSH, network, firmware, and API-port assertion with `0` failed and `0` unreachable hosts. Independent checks found no managed cluster path on any node; TCP 6443 and the controller kubeconfig are absent. All nodes now run the already-pinned `5.15.0-1105-raspi`; `linux-image-raspi` and `linux-raspi` are exactly `5.15.0.1105.103`, and fallback `linux-image-5.15.0-1102-raspi=5.15.0-1102.105` remains installed.
- Follow-ups: Obtain a fresh exact install confirmation, then run only the direct clean-install phase. Network bootstrap and GitOps remain separately gated. The recovery power-cycle activated the pinned target kernel on all three nodes simultaneously rather than through the planned serial kernel play; record this deviation in final acceptance.
