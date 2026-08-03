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
- Keep the production Pod CIDR, Service CIDR, and cluster DNS private and inventory-authoritative. Public examples use `10.244.0.0/16`, `10.96.0.0/16`, and `10.96.0.10`.
- Install every server with the declared network values and with Flannel, kube-proxy, the K3s network-policy controller, packaged Traefik, and ServiceLB disabled. Cilium alone owns CNI, cluster-pool IPAM, policy, and kube-proxy replacement.
- Before Cilium exists, map every server's required `k3s_node_name` to the exact Kubernetes node set and require each sole Ready condition to be `Ready=False`, reason `KubeletNotReady`, with `NetworkPluginNotReady` in its message. Reject Ready nodes because they can hide a third-party CNI; never add a temporary or default CNI. Reject conflicting packaged resources or an observable Pod/Service CIDR mismatch before apply.

- Treat reset, kernel activation, clean install, private Cilium bootstrap, and GitOps bootstrap as separate phases. Supply a fresh exact confirmation for each; no confirmation carries forward.

## Required sequence

1. Run both offline repository validation commands.
2. Confirm physical/serial recovery access and verified production host keys.
3. Run the guarded backup-free reset.
4. Activate only `5.15.0-1105-raspi`, serially, while K3s is absent.
5. Install `v1.36.2+k3s1` and form exactly three voting etcd `v3.6.12-k3s1` members.
6. Bootstrap private Cilium v1.20.0 from the controller without cert-manager or GitOps; require no Applications or PVCs.
7. Bootstrap GitOps from the controller and complete acceptance checks.

## Dependency-free Cilium bootstrap

- Validate the final private artifact against public source before transformation. Permit exactly five private API endpoint substitutions and the one inventory-declared cluster CIDR substitution; reject every other drift.
- Before any Cilium apply, and again after Cilium and DNS acceptance, require zero PVCs. If the Argo Application API exists, require zero Applications; an absent Application CRD is the expected clean-cluster case.
- Create the bootstrap artifact only on the controller in a mode-`0700` temporary directory with mode-`0600` files. Omit exactly the `kube-system/hubble-server-certs` cert-manager `Certificate`; change only the Cilium ConfigMap from `hubble-disable-tls: "false"` to `"true"`; re-read and assert the omission and exact transformation before apply.
- Remove the controller artifact in `always`. Hubble remains temporarily plaintext in-cluster until GitOps reconciliation, so do not expose or use Hubble and proceed directly to GitOps bootstrap.
- After apply, wait for the `cilium` and `cilium-envoy` DaemonSets, both `cilium-operator` replicas, every node to become Ready, and CoreDNS. Require healthy `cilium-dbg status` from each agent.
- Prove DNS with a uniquely named temporary Pod using immutable image `busybox@sha256:9db7b59979c38555a39def84a31fb98b5296952f9e3afd4f6f11f05b07adfab0`; delete it in `always` and assert absence.
- After cert-manager becomes available, require Argo self-heal to reapply the unchanged final private Cilium artifact, create the omitted Certificate, and restore Hubble TLS desired state.

The source install is also the final K3s version; no in-place upgrade or
embedded-etcd bridge is authorized. Applications and PVCs must remain absent
until GitOps bootstrap. Follow the runbook's repair-forward procedure on any
failure. HLP-012 owns future backup/DR design; it is not a rebuild gate and
authorizes no live NAS or cluster change.
