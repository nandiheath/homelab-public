# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Depends on: HLP-004

## Owned paths

- `ansible/playbooks/reset.yaml`
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

- Offline documentation and lifecycle validation are complete. The authorized reset reached its read-only capture and preflight, then stopped before mutation because remote `sudo` required an unavailable password.

## Completion handoff

- Summary: Repaired `ansible/playbooks/reset.yaml` to use `include_role` task entrypoints for capture, preflight, and final verification. The authorized reset did not mutate infrastructure.
- Files changed: `ansible/playbooks/reset.yaml`; `tasks/running/HLP-005-clean-cluster-rebuild.md`.
- Observed verification: Reset syntax and task expansion passed; `./scripts/validate-ansible.sh` and `./scripts/validate.sh` passed (`352` resources; `245` valid; `0` invalid; `0` errors; `107` skipped). The live reset captured non-secret host baselines, then failed at preflight privilege escalation with `sudo: a password is required`; no wipe task ran and no Kubernetes data was removed.
- Follow-ups: Provide the approved remote become credential through the controller's secure boundary, then supply a fresh exact reset confirmation and rerun only the reset phase. Later phases still require separate confirmations.
