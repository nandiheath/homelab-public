# HLP-006 — Guarded K3s upgrade

- Status: planned
- Owner: unassigned
- Depends on: HLP-001, HLP-002, HLP-005

## Owned paths

- `ansible/playbooks/upgrade.yaml`
- `ansible/roles/k3s_upgrade/`
- `tasks/planned/HLP-006-guarded-k3s-upgrade.md`

## Goal

Execute only the required embedded-etcd bridge upgrades with peer-driven serial safety gates.

## Implementation

Accept exact string target versions only. Derive uniform observed source and allow only 1.33.2→1.33.10 or 1.33.10→1.33.13. Upgrade secondary servers first and node 0 last via shared maintenance. Require 1.33.10 binaries, exact etcd 3.5.26 voting members, and Cilium/API/node health before final bridge; after each roll require uniform target binaries, exact target etcd release, three Ready nodes, and no skew. Never snapshot, restore, downgrade, or partially wipe/rejoin a damaged quorum.

## Acceptance criteria

- Only the two approved source-target boundaries reach sentineled mutation.
- Failure leaves the failed node cordoned and stops when health cannot be proven.
- No upgrade path implements backup, restore, or downgrade behavior.

## Verification

- Localhost fixture matrix for both boundaries and rejected source/target pairs.

## Blockers

- HLP-001, HLP-002, and HLP-005 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
