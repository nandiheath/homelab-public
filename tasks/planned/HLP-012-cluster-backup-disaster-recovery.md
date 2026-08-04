# HLP-012 — Cluster backup and disaster recovery

- Status: planned
- Owner: unassigned
- Milestone: HLP-M002
- Depends on: HLP-011

## Owned paths

- `tasks/planned/HLP-012-cluster-backup-disaster-recovery.md`
- `docs/backup-disaster-recovery.md`

## Goal

Produce a decision-ready backup and disaster-recovery design without changing the cluster, NAS, or credentials.

## Implementation

Investigate and document: reconstructible public/private GitOps plus 1Password desired state; embedded-etcd runtime state and its restoration limits; K3s embedded-etcd snapshot export, matching server-token custody, retention, encryption, version compatibility, integrity/authenticity, and isolated restore drills; Longhorn NFS/S3 targets, schedules, recurring jobs, retention, failure domains, and restore drills; NAS endpoint/export or object API, network/authentication, capacity/growth, snapshots, encryption, immutability, off-site copy, monitoring, and failure behavior; application-consistent CNPG base backups/WAL, Immich library, and retention/discard policies for Redis, Prometheus, and Grafana; RPO/RTO tiers, restore order, bootstrap dependencies, verification, destructive drill cadence, and evidence. End with implementation task contracts.

## Acceptance criteria

- Clearly distinguishes reconstructible desired state, etcd runtime state, Longhorn persistent data, and application consistency.
- Includes NAS inventory before recommendations and evaluates security, retention, and isolated restore drills.
- Defines decision-ready RPO/RTO and new path-owned implementation contracts.
- Does not mutate the cluster, NAS, or live credentials.

## Verification

- Validate task lifecycle and document references.

## Blockers

- HLP-011 must be rolled up; do not claim this task during the rebuild.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
