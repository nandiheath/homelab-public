# HLP-015 — Upgrade transaction correction

- Status: running
- Owner: UpgradeCorrection
- Depends on: HLP-011

## Owned paths

- `ansible/playbooks/upgrade.yaml`
- `ansible/roles/k3s_upgrade/`
- `ansible/roles/cluster_health/`
- `ansible/roles/node_maintenance/`
- `tasks/planned/HLP-015-upgrade-transaction-correction.md`

## Goal

Make each approved bridge use the full healthy-peer cordon, eviction drain, upgrade, exact etcd/API/Cilium verification, and safe uncordon transaction.

## Acceptance criteria

- Only the two approved uniform source/target boundaries execute; secondary servers precede node 0 in bootstrap mode.
- Every target uses the shared transaction and remains cordoned on disruptive failure; no PDB/eviction bypass exists.
- Pre/post checks prove exact voting etcd membership/version, Ready nodes, API/Cilium health, no skew, and no Applications/PVCs.

## Verification

- Focused Ansible lint and sentineled maintenance fixtures.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
