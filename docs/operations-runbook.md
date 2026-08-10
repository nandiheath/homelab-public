# K3s lifecycle operations runbook

> This procedure irreversibly destroys all Kubernetes runtime and persistent application data. It preserves Ubuntu, SSH access, host identity, networking, boot firmware, and the retained prior kernel. It intentionally creates no backup, snapshot, token export, recovery bundle, or restore point.

## Fixed lifecycle

| Stage | K3s | embedded etcd |
|---|---|---|
| Clean install and final | `v1.36.2+k3s1` | `v3.6.12-k3s1` |

The rebuild is a direct clean install; no embedded-etcd bridge or in-place
K3s upgrade is approved. Downgrade, partial destructive member rejoin,
eviction bypass, and PDB bypass are prohibited.

## Network contract

Private inventory is the authority for `cluster_cidr`, `service_cidr`, and
`cluster_dns`; never copy production values into this public repository. The
documentation-safe inventory example uses:

| Purpose | Inventory key | Public example | Enforced by |
|---|---|---|---|
| Pod addresses | `cluster_cidr` | `10.244.0.0/16` | K3s `--cluster-cidr` and Cilium `cluster-pool-ipv4-cidr` |
| Service virtual IPs | `service_cidr` | `10.96.0.0/16` | K3s `--service-cidr` |
| Cluster DNS service | `cluster_dns` | `10.96.0.10` | K3s `--cluster-dns` and post-Cilium DNS acceptance |

Every server starts with Flannel disabled and no default CNI, with kube-proxy,
the K3s network-policy controller, packaged Traefik, and ServiceLB disabled.
Cilium supplies the CNI, cluster-pool IPAM, network policy, and kube-proxy
replacement. Do not bootstrap over a cluster that contains evidence of the
disabled packaged components or reports a conflicting Pod or Service CIDR.

Set controller paths and the private inventory's exact cluster identity once:

```bash
export PUBLIC_REPO="$HOME/workspace/homelab-public"
export PRIVATE_REPO="$HOME/workspace/homelab-private"
export INVENTORY="$PRIVATE_REPO/ansible/inventory/production/hosts.yml"
export CLUSTER_ID="<cluster-id>"
export CONTROLLER_KUBECONFIG="$HOME/.kube/$CLUSTER_ID"
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
   homelab argocd render --all
   ./scripts/validate.sh
   cd "$PRIVATE_REPO"
   . ./bin/activate-hermit
   make render
   make validate
   "$PUBLIC_REPO/scripts/validate-repository-graph.sh" "$PRIVATE_REPO"
   cd "$PUBLIC_REPO"
   . ./bin/activate-hermit
   ```

4. Require the private Cilium artifact to contain exactly five `KUBERNETES_SERVICE_HOST` values equal to the private `api_endpoint`, contain the declared private `cluster_cidr` exactly once, contain neither public example value in those positions, and otherwise match the public source.
5. Confirm controller kubeconfig and any credential inputs are controller-owned mode `0600`. Confirm pinned installer, K3s binary, and kernel values match private inventory.
6. Confirm 1Password access without printing or persisting resolved values.
7. Capture the playbook's non-secret node, kernel, K3s, etcd, Application, and PVC report. Do not create backup evidence; backup/DR design belongs to deferred HLP-012.
8. Record the exact public and private repository revisions, controller tool versions, configured cluster identity, three healthy current voting etcd members, healthy API/Cilium, and current Application/PVC state in the non-secret handoff. Any mismatch stops before mutation.

Stop before mutation on any inventory/key mismatch, unexpected package state, insufficient boot capacity, degraded API/Cilium/node/etcd state outside the explicitly permitted pre-CNI condition, conflicting default K3s networking or packaged ingress evidence, live network-range mismatch, learner or stale member, checksum mismatch, token exposure, or desired-state drift.

## Authorization boundaries

Reset, kernel activation, clean install, private Cilium bootstrap, and GitOps
bootstrap are separate mutating phases. Supply the complete exact confirmation
freshly for each phase; a prior confirmation never authorizes a later phase.
Missing, boolean, stale-cluster, wrong-version, wrong-source, wrong-target, or
wrong-text input stops before the phase's mutation transaction.

## Destructive reset

Authorization must be exactly:

```text
RESET <cluster-id> AND DESTROY ALL KUBERNETES DATA
```

Run:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/reset.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "controller_kubectl=$CONTROLLER_KUBECTL" \
  -e "{\"operation_guard_confirmation\":\"RESET ${CLUSTER_ID} AND DESTROY ALL KUBERNETES DATA\"}"
```

The playbook removes agents first, secondary servers one at a time, and the initial server last. On partial failure, diagnose and finish the wipe; do not restore old cluster state. After completion require every host reachable with unchanged Ubuntu/SSH/network identity and require K3s services, processes, scripts, state, embedded etcd, CNI state, Longhorn state, TCP 6443 listeners, and controller kubeconfig absent.

## Activate the pinned Raspberry Pi kernel

Authorization must be exactly:

```text
ACTIVATE KERNEL 5.15.0-1105-raspi ON <cluster-id>
```

Run only in `cluster_absent` mode for this rebuild:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/kernel_upgrade.yaml \
  -e raspi_kernel_mode=cluster_absent \
  -e "{\"operation_guard_confirmation\":\"ACTIVATE KERNEL 5.15.0-1105-raspi ON ${CLUSTER_ID}\"}"
```

Only `linux-image-raspi=5.15.0.1105.103` and `linux-raspi=5.15.0.1105.103` may be installed. Do not run a distribution upgrade, generic latest upgrade, autoremove, firmware update, bootloader update, or OS release upgrade. After each serial reboot require SSH recovery, `uname -r` equal to `5.15.0-1105-raspi`, no reboot-required marker, expected boot files, retained `5.15.0-1102-raspi`, and continued K3s absence.

## Install the clean source cluster

Authorization must be exactly:

```text
INSTALL K3S v1.36.2+k3s1 ON <cluster-id>
```

Run:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/install.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "{\"operation_guard_confirmation\":\"INSTALL K3S v1.36.2+k3s1 ON ${CLUSTER_ID}\"}"
```

Require installer and arm64 binary checksum validation. Every server must use
structured arguments for the inventory-declared cluster CIDR, service CIDR,
and cluster DNS, and must disable Flannel, kube-proxy, the K3s network-policy
controller, packaged Traefik, and ServiceLB. Tokens may exist only in
root-owned mode-`0600` token files and must never appear in service arguments,
mode-`0644` units, logs, or cached facts. After every serial join require the
expected node identity, learner promotion, and healthy member count. Export
the controller kubeconfig only after exactly three voting etcd
`v3.6.12-k3s1` members are healthy. This source cluster is also the final
cluster; no upgrade play is authorized. Before Cilium, every node must be
NotReady solely because no CNI exists, and CoreDNS may remain unscheduled; do
not install a temporary or default CNI to make that phase appear healthy.

## Bootstrap private Cilium

Authorization must be exactly:

```text
BOOTSTRAP NETWORK <cluster-id>
```

Run from the controller:

```bash
ansible-playbook -i "$INVENTORY" ansible/playbooks/bootstrap_network.yaml \
  -e "kubeconfig=$CONTROLLER_KUBECONFIG" \
  -e "controller_kubectl=$CONTROLLER_KUBECTL" \
  -e "private_cilium_artifact=$PRIVATE_CILIUM" \
  -e "{\"operation_guard_confirmation\":\"BOOTSTRAP NETWORK ${CLUSTER_ID}\"}"
```

This phase requires only controller API access and the final private Cilium
artifact. It requires zero PVCs before and after Cilium. If the Argo Application
API exists, it also requires zero Applications at both boundaries; an absent
Application CRD is valid. No cert-manager CRD or other pre-existing workload is
required. Preflight maps each production inventory server's
required `k3s_node_name` to the exact three Kubernetes nodes at
`v1.36.2+k3s1`. Every node must report `Ready=False`, reason
`KubeletNotReady`, and a message containing `NetworkPluginNotReady`; a Ready
node can hide a pre-installed third-party CNI and is rejected. It rejects
Flannel, kube-proxy, packaged Traefik, ServiceLB, the wrong observable node Pod
CIDR, the wrong Kubernetes Service IP range, or a mismatched ServiceCIDR API
value before apply.

The playbook first proves that the final private artifact differs from public
source only by exactly five API endpoint substitutions and the declared
cluster CIDR substitution. On the controller it then creates a mode-`0700`
temporary directory containing mode-`0600` copies, omits exactly the
`kube-system/hubble-server-certs` cert-manager `Certificate`, and changes only
the Cilium ConfigMap's `hubble-disable-tls` value from `"false"` to `"true"`.
It re-reads and asserts that transformation before applying the temporary
artifact, and removes the directory in `always`.

Hubble traffic is temporarily plaintext after this apply. This is an explicit
unsafe bootstrap boundary: do not expose or use Hubble, do not treat the
temporary ConfigMap as final desired state, and proceed directly to GitOps
bootstrap. After cert-manager is available, Argo self-heal reapplies the
unchanged final private artifact, creates the omitted Certificate, and restores
Hubble TLS desired state.

Bootstrap waits for the `cilium` and `cilium-envoy` DaemonSets, both
`cilium-operator` replicas, every node to become Ready, and CoreDNS. It verifies
`cilium-dbg status` from every agent and resolves the Kubernetes service using
an immutable BusyBox DNS probe
`busybox@sha256:9db7b59979c38555a39def84a31fb98b5296952f9e3afd4f6f11f05b07adfab0`.
The uniquely named probe Pod is deleted in `always` and its absence is asserted.

## Bootstrap GitOps

> **Stop before live execution:** the 2026-08-09 bootstrap failed because Argo
> CD was ambient-enrolled before `istiod` and `ztunnel` existed. Publish the
> reviewed namespace and script fix at the revision used by the public root
> before running recovery.

Inspect the credential-free plan, then run the repository script from the
controller:

```bash
./scripts/bootstrap.sh --dry-run \
  --private-repository="$PRIVATE_REPOSITORY"

./scripts/bootstrap.sh \
  --kubeconfig="$CONTROLLER_KUBECONFIG" \
  --kubectl="$CONTROLLER_KUBECTL" \
  --private-repository="$PRIVATE_REPOSITORY"
```

Use `--force-conflicts` only for an intentional server-side apply ownership
transfer. It is passed to every bootstrap apply. Bootstrap has no authorization
argument; the operator-visible kubeconfig and context preflight remain its
live-target guard.

If the Connect Secrets are absent, provide the token and credentials JSON only
through the ignored `credentials/1password/` files documented in step 7. The
script does not place secret values in process arguments and reuses existing
Secrets during recovery.

The script keeps `argocd` and `istio-system` outside ambient mode, applies and
verifies Istio base, `istiod`, Istio CNI, and ztunnel, then applies or restarts
Argo CD. It seeds `core-infrastructure-aoa` and `private-aoa`, waits for both
Application objects to exist, and stops. Argo CD performs every child
Application reconciliation and all workload convergence.

Use `./scripts/prune.sh --reset` with the same kubeconfig, kubectl, and private
repository arguments to remove direct bootstrap manifests in reverse order.
The mandatory reset flag prevents accidental teardown; Application finalizers
are cleared first to avoid cascading deletion of GitOps-managed workloads.

## Acceptance

Require all of the following before closing the maintenance window:

- Three Ready nodes at `v1.36.2+k3s1`; three healthy voting etcd `v3.6.12-k3s1` members; no learner, stale member, or version skew.
- Healthy API and Cilium; the Cilium and Cilium Envoy DaemonSets are rolled out, both operator replicas are available, all nodes are Ready, and the temporary DNS probe has proved cluster DNS and been removed. Cilium tracks the unchanged final private artifact with Hubble TLS restored, and no production resource contains `192.0.2.11` or the public example Pod CIDR.
- Argo CD, 1Password Connect, External Secrets, Longhorn, CNPG, ingress, public root, and private root are Healthy; every expected Application is Synced and Healthy; no legacy Argo owner remains.
- Exactly five newly created Bound PVCs and clean/empty application smoke-test results.
- No temporary credential file on controller or node and no token in process arguments, units, logs, or fact cache.
- Longhorn desired state reports `defaultSettings.nodeDrainPolicy: block-for-eviction`; no backup target or recurring backup job was added.

Deferred GitHub App key rotation, repository archival, and HLP-012 backup/DR investigation remain separate work. HLP-012 authorizes no live NAS, credential, or cluster mutation.
