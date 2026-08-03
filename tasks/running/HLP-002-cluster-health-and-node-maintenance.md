# HLP-002 — Cluster health and node maintenance

- Status: running
- Owner: ClusterHealthMaintenance
- Depends on: HLP-001

## Owned paths

- `ansible/roles/cluster_health/`
- `ansible/roles/node_maintenance/`
- `tasks/planned/HLP-002-cluster-health-and-node-maintenance.md`

## Goal

Provide structured cluster health checks and a fail-closed serial disruptive-maintenance transaction.

## Implementation

Parse Kubernetes JSON only. Validate expected nodes, Ready state, three healthy voting etcd members without learner/stale members, API readyz etcd, required controllers, schedulability, workload readiness, PVC/Longhorn/CNPG health when expected, and bare-cluster absence of Applications/PVCs. Implement healthy-peer `cordon → drain → mutate/reboot/restart → verify → uncordon` with Eviction API, DaemonSet ignore, acknowledged emptyDir deletion, serial one, and fatal failures. Never bypass PDBs, disable eviction, or force-delete unmanaged pods. Refuse node 0 except narrowly defined bootstrap mode.

## Acceptance criteria

- Health gates reject degraded API, Cilium, node, etcd, workload, PDB, or bare-cluster state.
- Maintenance leaves failed disruptive targets cordoned unless safe rescue conditions are proven.
- No operation disables eviction or bypasses PDB protection.

## Verification

- Focused localhost fixture matrix with sentineled mutation commands.

## Blockers

- HLP-001 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
