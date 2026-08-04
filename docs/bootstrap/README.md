# Cluster bootstrap guide

Use this sequence to build or rebuild the three-server K3s cluster. Each step is intentionally short; the linked lifecycle playbooks and [`../operations-runbook.md`](../operations-runbook.md) remain the exact operational authority.

Never copy production topology, addresses, host keys, cluster identity, credentials, or resolved private manifests into this public repository. A future agent must obtain those values from the private inventory and approved secret boundary at execution time.

## Choose the route

| Route | Sequence |
|---|---|
| New Raspberry Pi hosts | 1 → 2 → 4 → 5 → 6 → 7 → 8 |
| Destructive rebuild of existing hosts | 2 → 3 → 4 → 5 → 6 → 7 → 8 |
| Approved in-place K3s upgrade | 2 → 9 → 8 |

Do not run step 3 against unused hosts merely to make the routes look identical. Do not run step 5 as an upgrade mechanism.

## Numbered steps

| Step | Guide | Applies to |
|---|---|---|
| 1 | [Install the Raspberry Pis](1_install_raspberry_pi.md) | Initial host bootstrap only |
| 2 | [Prepare the controller and private inputs](2_prepare_controller.md) | Bootstrap, rebuild, and upgrade |
| 3 | [Reset an existing cluster](3_reset_existing_cluster.md) | Destructive rebuild only |
| 4 | [Activate the pinned kernel](4_activate_pinned_kernel.md) | Bootstrap/rebuild; upgrade only when separately approved |
| 5 | [Install K3s](5_install_k3s.md) | Initial bootstrap or destructive rebuild only |
| 6 | [Bootstrap private Cilium](6_bootstrap_cilium.md) | Initial bootstrap or destructive rebuild only |
| 7 | [Bootstrap GitOps](7_bootstrap_gitops.md) | Initial bootstrap, destructive rebuild, or GitOps recovery |
| 8 | [Verify final acceptance](8_verify_cluster.md) | Bootstrap, rebuild, and upgrade |
| 9 | [Upgrade K3s](9_upgrade_k3s.md) | Cluster upgrade only |

## Deliberate incomplete states

Some intermediate states are intentionally unhealthy or unsafe. Never normalize them into a final state.

| Boundary | Expected state | Resolved by |
|---|---|---|
| Newly imaged host | Image kernel may not match the reviewed pin. The legacy boot-volume helper also has workstation-specific assumptions. | Step 2 verifies identity and inputs; step 4 installs and activates the exact kernel. |
| Clean K3s install | Nodes are `NotReady` only because no CNI exists; CoreDNS may be pending. | Step 6 installs private Cilium. |
| Private Cilium bootstrap | Hubble TLS is deliberately disabled and its Certificate is omitted. Hubble must not be exposed or used. | Step 7 lets cert-manager and Argo self-heal restore the final TLS-enabled Cilium artifact. |
| K3s upgrade request | The guard currently has no default upgrade path. This is fail-closed, not a missing flag to bypass. | A future reviewed change must declare the exact source/target bridge, checksums, etcd versions, and fixture proof before step 9 can run. |
| Backup-free rebuild | The reset creates no backup, snapshot, token export, or restore point. | Not resolved by this sequence; backup/DR remains separate work. |

## Rules for every mutating step

- Read `AGENTS.md`, `skills/k3s-lifecycle/SKILL.md`, the private repository instructions, the active task contract, and the exact operations runbook section first.
- Run only from a clean, reviewed revision with physical or serial recovery access.
- Preserve strict host-key checking. Never trust `ssh-keyscan`, `accept-new`, a first-use prompt, `/dev/null` known-hosts, or a mismatched key.
- Run offline validation and read-only preflight before requesting authorization.
- Obtain the complete exact confirmation in the current conversation for that phase. Authorization never carries to the next phase.
- Stop on any unexpected state. Do not add bypasses, temporary defaults, retries, or ad-hoc repair commands.
- Record non-secret acceptance evidence and keep all resolved credentials, kubeconfigs, token files, and private artifacts mode-restricted and outside Git.
