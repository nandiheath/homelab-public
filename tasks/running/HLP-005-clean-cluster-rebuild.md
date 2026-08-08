# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Milestone: HLP-M003
- Depends on: HLP-004

## Owned paths
- `ansible/roles/operation_guard/`
- `ansible/roles/raspi_kernel/`
- `ansible/roles/raspberry_pi/files/scripts/setup-boot-volume.sh`

- `ansible/playbooks/reset.yaml`
- `ansible/playbooks/bootstrap_network.yaml`
- `ansible/roles/k3s_reset/tasks/preflight.yml`
- `ansible/roles/k3s_reset/tasks/capture_host_facts.yml`
- `ansible/roles/k3s_reset/tasks/assert_absence.yml`
- `ansible/roles/k3s_reset/defaults/main.yml`
- `ansible/roles/cluster_health/tasks/main.yml`
- `ansible/roles/k3s_server/tasks/main.yml`
- `ansible/roles/k3s_server/defaults/main.yml`
- `ansible/roles/k3s_server/tasks/validate_network.yml`
- `ansible/roles/k3s_server/templates/`
- `ansible/inventory.example.yml`
- `tests/ansible_lifecycle/run-entrypoints.sh`
- `tests/ansible_lifecycle/run-fixtures.sh`
- `tests/ansible_lifecycle/k3s_network_contract.yml`
- `tests/ansible_lifecycle/inventory.yml`
- `skills/k3s-lifecycle/SKILL.md`
- `tasks/running/HLP-005-clean-cluster-rebuild.md`
- `ansible/playbooks/fetch_kubeconfig.yaml`
- `ansible/playbooks/bootstrap_gitops.yml`
- `ansible/roles/k3s_server/tasks/export_kubeconfig.yml`
- `ansible/roles/k3s_server/tasks/resolve_kubeconfig_endpoint.yml`
- `argocd/infrastructure/bootstrap/`
- `argocd/infrastructure/infrastructure-app-of-apps/`
- `artifacts/infrastructure/bootstrap/`
- `artifacts/infrastructure/infrastructure-app-of-apps/`
- `scripts/bootstrap.sh`
- `scripts/validate-repository-graph.sh`
- `docs/bootstrap/7_bootstrap_gitops.md`
- `docs/operations-runbook.md`
- `AGENTS.md`
- `README.md`

## Goal

Define the guarded backup-free reset and direct latest-minor K3s rebuild while preserving host identity and enforcing explicit authorization at every mutating phase.

## Implementation

Update the operator runbook and lifecycle skill for the direct `v1.36.2+k3s1` install with embedded etcd `v3.6.12-k3s1`, pinned Raspberry Pi kernel activation, private Cilium v1.20.0 bootstrap, and controller-only GitOps bootstrap. Require recovery readiness, independently verified host keys, exact repository/tool/version handoff, current cluster health, no backup contract, and a fresh exact confirmation for reset, kernel, install, network, and GitOps phases.

## Acceptance criteria

- Direct clean install forms exactly three healthy voting embedded-etcd members at `v1.36.2+k3s1` / `v3.6.12-k3s1`, with the exact pod/service/DNS ranges and built-in network components disabled; pre-CNI nodes may remain only `NetworkPluginNotReady`. Private Cilium then bootstraps without pre-existing pod networking or cert-manager, makes every node Ready, and GitOps restores the final TLS-enabled desired state without premature Applications/PVCs.
- Every mutating phase requires its own exact current-session confirmation; missing, boolean, stale, wrong-version, wrong-source, wrong-target, or wrong-text inputs stop before mutation.
- Reset preserves Ubuntu, SSH configuration and keys, hostname, users, networking, boot firmware, and retained fallback kernel while removing Kubernetes-owned state without backup inputs.
- Kernel activation is serial, exact-package, cluster-absent, and verifies node return, pinned kernel, fallback, boot files, and K3s absence.
- Final acceptance proves node/API/Cilium health, expected GitOps health, exactly five Bound PVCs, empty smoke tests, no token/credential residue, and no backup policy.
- The released `homelab kubeconfig` command atomically writes a verified mode-`0600` controller kubeconfig, defaults to a certificate-valid stable API endpoint, and uses only an explicit direct-node mode before the stable endpoint exists or during recovery. Stable mode never silently falls back to a server address.
- The released `homelab bootstrap` command wraps this playbook as the only operational GitOps entrypoint. It validates the selected context and bare-cluster health before mutation, applies the exact dependency-ordered public controllers and private bootstrap resources, hands seeded resource ownership to Argo CD, and never serializes credential values into command arguments.

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`
- `source ./bin/activate-hermit && ./scripts/validate.sh`
- Live reset, install, cluster, router, and remote-host operations require explicit current-session authorization. No authorization has been supplied for another reset/reinstall or for Cilium bootstrap.

## Blockers

- Offline kubeconfig/bootstrap CLI integration is implemented and validated in the feature worktrees. Live GitOps remains blocked until the CLI is released and pinned and a fresh exact `BOOTSTRAP <cluster-id>` authorization is supplied.

## Completion handoff

- Summary: The earlier authorized reset and three-server install preserved the hosts and formed healthy embedded etcd, but the legacy free-form network arguments were not passed to the K3s installer. The offline repair replaces that contract with validated role-owned Pod/Service/DNS and disabled-component arguments, pins explicit Kubernetes node identities, requires the exact pre-CNI `NetworkPluginNotReady` state, and makes Cilium bootstrap independent of pre-existing CNI, DNS, cert-manager, and GitOps. Bootstrap applies a mode-restricted temporary copy that omits only the Hubble `Certificate` and disables Hubble TLS, then verifies Cilium, node readiness, CoreDNS, DNS resolution, and zero Applications/PVCs before removing all temporary resources.
- Files changed: `AGENTS.md`; `ansible/playbooks/bootstrap_network.yaml`; `ansible/roles/operation_guard/`; `ansible/roles/raspberry_pi/files/scripts/setup-boot-volume.sh`; `ansible/roles/k3s_server/defaults/main.yml`; `ansible/roles/k3s_server/tasks/main.yml`; `ansible/roles/k3s_server/tasks/validate_network.yml`; `ansible/roles/k3s_server/templates/`; `ansible/inventory.example.yml`; `tests/ansible_lifecycle/inventory.yml`; `tests/ansible_lifecycle/k3s_network_contract.yml`; `tests/ansible_lifecycle/run-fixtures.sh`; `tests/ansible_lifecycle/run-entrypoints.sh`; `docs/operations-runbook.md`; `skills/k3s-lifecycle/SKILL.md`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private inventory, renderer, validation, Cilium source/artifact, topology documentation, and global cross-repository knowledge reference.
- Kernel-phase files changed: `ansible/roles/raspi_kernel/defaults/main.yml`; `ansible/roles/raspi_kernel/tasks/main.yml`. The role now distinguishes `/boot` kernel artifacts from `/boot/firmware` capacity, accepts an already-active pinned kernel for safe resume, and skips capacity/install/reboot work only when exact pinned packages and the target kernel are already active.
- Observed verification: The prior authorized reset/install completed with `0` failed and `0` unreachable hosts and produced three unique healthy `v3.6.12` voting members at K3s `v1.36.2+k3s1`; later inspection proved the installed unit omitted the intended network arguments, so that live result is not accepted as the clean-cluster network state. After the offline repair and public sanitization, `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`, `./scripts/validate.sh`, and `./scripts/validate-repository-graph.sh ../homelab-private` all passed. A repository-wide search found no production cluster identity, workstation absolute path, production node identity, or private address range in the public repository. Private rendering and `make validate` also passed. No live cluster, router, or remote-host mutation was performed during this repair.
- Kernel-phase evidence: the exact `ACTIVATE KERNEL 5.15.0-1105-raspi ON <cluster-id>` authorization was recorded for the private production identity. The guarded serial play completed with every node at `ok=25 changed=0 unreachable=0 failed=0`; all exact package, active-kernel, retained-fallback, boot-file, package-integrity, and K3s-absence assertions passed. Independent strict-SSH checks returned all three inventory-declared hosts on `5.15.0-1105-raspi`, found both target and fallback boot files, and confirmed K3s paths/service absent. Every API port was closed and the controller kubeconfig remained absent. Post-phase `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, `./scripts/validate-repository-graph.sh ../homelab-private`, and private `make validate` passed.
- Install-phase evidence: the exact `INSTALL K3S v1.36.2+k3s1 ON <cluster-id>` authorization was recorded for the private production identity. The guarded serial install ended with each node at `unreachable=0 failed=0`, validated the installer and ARM64 binary checksums, and exported a mode-`0600` controller kubeconfig. Embedded etcd reported three unique healthy voting non-learners at the required version, one leader, and two active peers from every member. Independent unit inspection found the inventory-declared Pod, Service, and DNS network values and all five required disabled components on every server; joiners use a root-owned mode-`0600` token file and no legacy environment file remains. Kubernetes reported exactly the three inventory-declared nodes at `v1.36.2+k3s1`, each NotReady solely with `NetworkPluginNotReady`, using distinct Pod subnets within the declared cluster CIDR. There were zero PVCs, no Argo CD Application CRD, and no daemonsets before Cilium.
- Network-phase evidence: the exact `BOOTSTRAP NETWORK <cluster-id>` authorization was recorded for the private production identity. The first invocation used a relative private-artifact path and stopped during preflight before apply; the absolute-path retry proved the public/private artifact substitution boundary, created mode-restricted temporary copies, omitted the Hubble Certificate, changed only `hubble-disable-tls` to `"true"`, applied Cilium v1.20.0, rolled out both daemonsets and both operator replicas, made every exact node Ready, and removed the controller artifact. Its final `cilium-dbg status --brief` check expected obsolete verbose strings even though every agent returned exit zero and exact output `OK`; `ansible/playbooks/bootstrap_network.yaml` now validates that current contract and `./scripts/validate-ansible.sh` passes. Independent post-apply checks returned `OK` from all three Cilium agents, successful Cilium/Envoy/operator/CoreDNS rollouts, and all inventory-declared nodes Ready on the expected Pod subnets. A temporary immutable BusyBox probe resolved the Kubernetes service through the declared cluster DNS, then was deleted and proved absent. PVC count remains zero, the Argo Application CRD remains absent, Hubble TLS is temporarily disabled, and no cert-manager API exists.
- Bootstrap-CLI implementation evidence: `homelab kubeconfig` now forwards only JSON extra-vars, selects stable or explicit direct mode, verifies a mode-`0600` result, and restores a protected pre-existing file after child or post-validation failure. `homelab bootstrap` validates the reviewed repositories and mode-restricted kubeconfig, forwards only paths, tool names, and exact authorization, and inherits credential manifests only from the environment. The public lifecycle resolves and validates the requested kubeconfig endpoint, then the GitOps transaction proves selected context, exact API/node/etcd/Cilium bare-cluster health, performs the dependency-ordered public/private apply, waits for Cilium TLS restoration and both roots, transfers seed ownership, and removes credential files in `always`. Deterministic fixtures exercised the accepted sequence plus an injected failure at every mutation boundary. `go test ./...`, `go vet ./...`, CLI build/help smoke checks, public `validate-ansible.sh`, public `validate.sh` (`349` resources; `245` valid, `0` invalid, `0` errors, `104` schema-skipped), private `make validate`, two byte-identical private renders (`61` files; SHA-256 tree digest `5382251b3318eadbea21af225d3cd6a037fa672ca997d8f65efe2ea0bf4ddbd6`), and the cross-repository graph validator passed without live infrastructure access.
- Follow-ups: Obtain a fresh exact GitOps confirmation immediately, restore the final TLS-enabled Cilium desired state through Argo self-heal, and complete final Applications, PVCs, smoke-test, and credential-residue acceptance.
