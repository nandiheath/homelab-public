# HLP-003 — Destructive K3s reset

- Status: running
- Owner: DestructiveReset
- Depends on: HLP-001, HLP-002

## Owned paths

- `ansible/playbooks/reset.yaml`
- `ansible/roles/k3s_reset/`
- `tasks/planned/HLP-003-destructive-k3s-reset.md`

## Goal

Perform the approved irreversible, backup-free K3s data wipe while preserving each host's operating system identity and connectivity.

## Implementation

Guard reset with the exact destructive literal and immediately recheck host identity, API, etcd membership, and inventory. Emit only non-secret observed facts. Remove agents, secondary servers serially, and initial server last using the generated uninstall entrypoints, then remove only K3s/Cilium/Longhorn residue. Assert absence after every host and controller kubeconfig removal only once after all hosts. Create or fetch no backup, snapshot, token, archive, manifest, signature, or recovery artifact.

## Acceptance criteria

- Wrong confirmation cannot reach a sentineled reset mutation; the exact literal can without backup inputs.
- Reset preserves Ubuntu, SSH keys/config, hostname, users, network, and boot firmware.
- A partial failure stops before remaining hosts are changed.

## Verification

- Localhost sentineled reset fixture plus syntax/lint checks.

## Blockers

- HLP-001 and HLP-002 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
