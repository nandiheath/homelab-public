# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Depends on: HLP-004

## Owned paths

- `ansible/playbooks/reset.yaml`
- `ansible/roles/k3s_reset/tasks/preflight.yml`
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

- The preflight now enumerates remote users through the pinned `/usr/bin/python3` `pwd` module, avoiding unavailable `getent` binaries and controller PATH lookup. The current retry is ready for another authorized reset run.

## Completion handoff

- Summary: Repaired `ansible/playbooks/reset.yaml` to use `include_role` task entrypoints and repaired `ansible/roles/k3s_reset/tasks/preflight.yml` to enumerate remote users through Python.
- Files changed: `ansible/playbooks/reset.yaml`; `ansible/roles/k3s_reset/tasks/preflight.yml`; `tasks/running/HLP-005-clean-cluster-rebuild.md`.
- Observed verification: Reset syntax and task expansion passed; `./scripts/validate-ansible.sh` and `./scripts/validate.sh` passed (`352` resources; `245` valid; `0` invalid; `0` errors; `107` skipped). Privileged `/usr/bin/python3` user enumeration passed on all three nodes. No wipe task, reboot, install, network bootstrap, GitOps bootstrap, or Kubernetes data mutation has run.
- Follow-ups: Rerun with `--ask-become-pass` / `-K` and the exact reset confirmation. Later phases still require separate confirmations.
