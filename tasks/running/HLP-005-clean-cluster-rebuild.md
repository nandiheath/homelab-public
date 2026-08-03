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
- `ansible/roles/k3s_server/tasks/main.yml`
- `ansible/roles/k3s_server/defaults/main.yml`
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

- Clean K3s install acceptance is complete. Private Cilium bootstrap is the next live phase and requires its own fresh exact current-session confirmation before any mutation.

## Completion handoff

- Summary: Completed and live-verified the guarded backup-free reset, interrupted-reset recovery, and direct three-server K3s install. The install validates embedded etcd from each server's local metrics endpoint, supports safe forward resumption after an interrupted serial join, waits for each joined node to become Ready, and keeps the join token in a root-only file.
- Files changed: `ansible/playbooks/reset.yaml`; `ansible/roles/k3s_reset/defaults/main.yml`; `ansible/roles/k3s_reset/tasks/preflight.yml`; `ansible/roles/k3s_reset/tasks/capture_host_facts.yml`; `ansible/roles/k3s_reset/tasks/assert_absence.yml`; `ansible/roles/cluster_health/tasks/main.yml`; `ansible/roles/k3s_server/defaults/main.yml`; `ansible/roles/k3s_server/tasks/main.yml`; `tests/ansible_lifecycle/run-entrypoints.sh`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private `ansible/inventory/production/hosts.yml`.
- Observed verification: Reset preservation and absence acceptance passed on all three nodes. The authorized install then completed with `0` failed and `0` unreachable hosts. Controller `/readyz` returned `ok`; all three inventory servers are Ready `control-plane,etcd` nodes at `v1.36.2+k3s1`, with unchanged addresses and the pinned `5.15.0-1105-raspi` kernel. Local metrics independently reported three unique `v3.6.12` voting etcd members, one leader, no learners, and both peer IDs active from every member. The controller kubeconfig was exported to `~/.kube/homelab-production` with mode `0600`, context `homelab`, and a working API endpoint. Public syntax, lifecycle entrypoint, Ansible, manifest, graph, private inventory, and private `make validate` checks passed. The recovery power-cycle activated the target kernel simultaneously rather than through the planned serial kernel play.
- Follow-ups: Obtain the separate `BOOTSTRAP NETWORK homelab-production` confirmation and complete private Cilium acceptance. Then obtain the separate GitOps confirmation and prove the final Applications, PVCs, smoke tests, and credential-residue criteria.
