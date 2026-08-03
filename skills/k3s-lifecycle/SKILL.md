---
name: k3s-lifecycle
description: Safely operate the homelab-production K3s reset, Raspberry Pi kernel activation, direct clean install, and controller GitOps bootstrap.
---

# K3s lifecycle

Read `docs/operations-runbook.md`, `PROJECT_STATUS.md`, the private production inventory, and the active task before any operation.

## Invariants

- Require current-session authorization and the complete exact literal for every mutating entrypoint.
- Require independently verified SSH host-key pins. Never use `ssh-keyscan`, trust-on-first-use, `accept-new`, `StrictHostKeyChecking=no`, or `/dev/null` known-hosts as trust evidence.
- This rebuild intentionally destroys Kubernetes, embedded-etcd, Longhorn, CNPG, PVC, and application data. Do not create or require a snapshot, backup, token export, recovery bundle, signer, or restore proof.
- Preserve Ubuntu, SSH configuration and keys, hostname, users, networking, `/boot/firmware`, and the retained prior kernel.
- Stop on inventory/key mismatch, package drift, insufficient boot space, node non-return, PDB/drain failure, learner/stale/degraded etcd, API/Cilium failure, checksum mismatch, token exposure, or desired-state drift.
- Never bypass eviction/PDBs, force-delete unmanaged pods, downgrade an existing datastore, or partially wipe/rejoin a damaged quorum.

- Treat reset, kernel activation, clean install, private Cilium bootstrap, and GitOps bootstrap as separate phases. Supply a fresh exact confirmation for each; no confirmation carries forward.

## Required sequence

1. Run both offline repository validation commands.
2. Confirm physical/serial recovery access and verified production host keys.
3. Run the guarded backup-free reset.
4. Activate only `5.15.0-1105-raspi`, serially, while K3s is absent.
5. Install `v1.36.2+k3s1` and form exactly three voting etcd `v3.6.12-k3s1` members.
6. Bootstrap private Cilium v1.20.0 from the controller; require no Applications or PVCs.
7. Bootstrap GitOps from the controller and complete acceptance checks.

The source install is also the final K3s version; no in-place upgrade or
embedded-etcd bridge is authorized. Applications and PVCs must remain absent
until GitOps bootstrap. Follow the runbook's repair-forward procedure on any
failure. HLP-012 owns future backup/DR design; it is not a rebuild gate and
authorizes no live NAS or cluster change.
