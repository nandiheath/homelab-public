# K3s lifecycle operations runbook

> This procedure irreversibly destroys all Kubernetes runtime and persistent application data. It preserves Ubuntu, SSH access, host identity, networking, boot firmware, and the retained prior kernel. It intentionally creates no backup, snapshot, token export, recovery bundle, or restore point.

## Fixed lifecycle

| Stage | K3s | embedded etcd |
|---|---|---|
| Clean install and final | `v1.36.2+k3s1` | `v3.6.12-k3s1` |

The rebuild is a direct clean install; no embedded-etcd bridge or in-place
K3s upgrade is approved. Downgrade, partial destructive member rejoin,
eviction bypass, and PDB bypass are prohibited.

Set controller paths once:

```bash
export PUBLIC_REPO=/Users/nandi/workspace/homelab-public
export PRIVATE_REPO=/Users/nandi/workspace/homelab-private
export INVENTORY="$PRIVATE_REPO/ansible/inventory/production/hosts.yml"
export CONTROLLER_KUBECONFIG="$HOME/.kube/homelab-production"
export CONTROLLER_KUBECTL="$PUBLIC_REPO/bin/kubectl"
export PRIVATE_CILIUM="$PRIVATE_REPO/artifacts/infrastructure/cilium"
cd "$PUBLIC_REPO"
. ./bin/activate-hermit
```

## Mandatory preflight

1. Reserve working physical or serial recovery access to all three Raspberry Pis. A node that does not return after reboot stops the whole procedure.
2. From each trusted local/serial console, obtain the active public SSH host key and SHA256 fingerprint. Record the verified public key in private inventory. Never establish trust with `ssh-keyscan`, `accept-new`, a first SSH prompt, `StrictHostKeyChecking=no`, or `/dev/null` known-hosts.
3. Require private inventory parsing and both repository validations:

   ```bash
   ansible-inventory -i "$INVENTORY" --list >/dev/null
   ./scripts/validate-ansible.sh
   ./scripts/validate.sh
   cd "$PRIVATE_REPO"
   . ./bin/activate-hermit
   make validate
   ./scripts/render.sh --all --application
   ./scripts/render.sh --all --infra
   "$PUBLIC_REPO/scripts/validate-repository-graph.sh" "$PRIVATE_REPO"
   cd "$PUBLIC_REPO"
   . ./bin/activate-hermit
   ```

4. Require the private Cilium artifact to contain exactly five `KUBERNETES_SERVICE_HOST` values equal to the private `api_endpoint`, contain no `192.0.2.11`, and otherwise match the public source.
5. Confirm controller kubeconfig and any credential inputs are controller-owned mode `0600`. Confirm pinned installer, K3s binary, and kernel values match private inventory.
6. Confirm 1Password access without printing or persisting resolved values.
7. Capture the playbook's non-secret node, kernel, K3s, etcd, Application, and PVC report. Do not create backup evidence; backup/DR design belongs to deferred HLP-012.
8. Record the exact public and private repository revisions, controller tool versions, cluster identity `homelab-production`, three healthy current voting etcd members, healthy API/Cilium, and current Application/PVC state in the non-secret handoff. Any mismatch stops before mutation.

Stop before mutation on any inventory/key mismatch, unexpected package state, insufficient boot capacity, degraded API/Cilium/node/etcd state, learner or stale member, checksum mismatch, token exposure, or desired-state drift.

## Authorization boundaries

Reset, kernel activation, clean install, private Cilium bootstrap, and GitOps
bootstrap are separate mutating phases. Supply the complete exact confirmation
freshly for each phase; a prior confirmation never authorizes a later phase.
Missing, boolean, stale-cluster, wrong-version, wrong-source, wrong-target, or
wrong-text input stops before the phase's mutation transaction.

## Destructive reset

Authorization must be exactly:

```text
RESET homelab-production AND DESTROY ALL KUBERNETES DATA
```

Run:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/reset.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "controller_kubectl=$CONTROLLER_KUBECTL" \
  -e '{"operation_guard_confirmation":"RESET homelab-production AND DESTROY ALL KUBERNETES DATA"}'
```

The playbook removes agents first, secondary servers one at a time, and the initial server last. On partial failure, diagnose and finish the wipe; do not restore old cluster state. After completion require every host reachable with unchanged Ubuntu/SSH/network identity and require K3s services, processes, scripts, state, embedded etcd, CNI state, Longhorn state, TCP 6443 listeners, and controller kubeconfig absent.

## Activate the pinned Raspberry Pi kernel

Authorization must be exactly:

```text
ACTIVATE KERNEL 5.15.0-1105-raspi ON homelab-production
```

Run only in `cluster_absent` mode for this rebuild:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/kernel_upgrade.yaml \
  -e raspi_kernel_mode=cluster_absent \
  -e '{"operation_guard_confirmation":"ACTIVATE KERNEL 5.15.0-1105-raspi ON homelab-production"}'
```

Only `linux-image-raspi=5.15.0.1105.103` and `linux-raspi=5.15.0.1105.103` may be installed. Do not run a distribution upgrade, generic latest upgrade, autoremove, firmware update, bootloader update, or OS release upgrade. After each serial reboot require SSH recovery, `uname -r` equal to `5.15.0-1105-raspi`, no reboot-required marker, expected boot files, retained `5.15.0-1102-raspi`, and continued K3s absence.

## Install the clean source cluster

Authorization must be exactly:

```text
INSTALL K3S v1.36.2+k3s1 ON homelab-production
```

Run:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/install.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e '{"operation_guard_confirmation":"INSTALL K3S v1.36.2+k3s1 ON homelab-production"}'
```

Require installer and arm64 binary checksum validation. Tokens may exist only
in root-owned mode-`0600` token files and must never appear in service
arguments, mode-`0644` units, logs, or cached facts. After every serial join
require the expected node identity, learner promotion, and healthy member
count. Export the controller kubeconfig only after exactly three voting etcd
`v3.6.12-k3s1` members are healthy. This source cluster is also the final
cluster; no upgrade play is authorized.

## Bootstrap private Cilium

Authorization must be exactly:

```text
BOOTSTRAP NETWORK homelab-production
```

Run from the controller:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/bootstrap_network.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "controller_kubectl=$CONTROLLER_KUBECTL" \
  -e "private_cilium_artifact=$PRIVATE_CILIUM" \
  -e '{"operation_guard_confirmation":"BOOTSTRAP NETWORK homelab-production"}'
```

Require three Ready `v1.36.2+k3s1` nodes, healthy API and private-endpoint Cilium, exactly three voting etcd `v3.6.12-k3s1` members, no token exposure, and zero Argo Applications and PVCs. Cilium is pinned to immutable v1.20.0 images and its release documentation records Kubernetes 1.36 compatibility.

## Bootstrap GitOps

Authorization must be exactly:

```text
BOOTSTRAP homelab-production
```

Resolve required credential-manifest content through the approved 1Password environment boundary without printing it, then run:

```bash
op run -- ansible-playbook -i "$INVENTORY" ansible/playbooks/bootstrap_gitops.yml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "controller_kubectl=$CONTROLLER_KUBECTL" \
  -e '{"operation_guard_confirmation":"BOOTSTRAP homelab-production"}'
```

The playbook runs kubectl only on the controller, creates mode-`0600` temporary credential files immediately before no-log apply, and deletes them in `always`. Ordering is Argo CD, External Secrets, 1Password Connect, temporary credentials, repository credentials, public root, then private root. GitOps bootstrap never installs or changes K3s.

## Acceptance

Require all of the following before closing the maintenance window:

- Three Ready nodes at `v1.36.2+k3s1`; three healthy voting etcd `v3.6.12-k3s1` members; no learner, stale member, or version skew.
- Healthy API and Cilium; Cilium tracks the private artifact and no production resource contains `192.0.2.11`.
- Argo CD, 1Password Connect, External Secrets, Longhorn, CNPG, ingress, public root, and private root are Healthy; every expected Application is Synced and Healthy; no legacy Argo owner remains.
- Exactly five newly created Bound PVCs and clean/empty application smoke-test results.
- No temporary credential file on controller or node and no token in process arguments, units, logs, or fact cache.
- Longhorn desired state reports `defaultSettings.nodeDrainPolicy: block-for-eviction`; no backup target or recurring backup job was added.

Deferred GitHub App key rotation, repository archival, and HLP-012 backup/DR investigation remain separate work. HLP-012 authorizes no live NAS, credential, or cluster mutation.
