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
- `argocd/infrastructure/core-infrastructure-aoa/`
- `artifacts/infrastructure/bootstrap/`
- `artifacts/infrastructure/core-infrastructure-aoa/`
- `scripts/bootstrap.sh`
- `scripts/prune.sh`
- `tests/bootstrap/run.sh`
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
- The guarded repository `scripts/bootstrap.sh` is the operational GitOps entrypoint. It validates the selected controller context and cluster health, installs the complete Istio ambient data plane before Argo CD, keeps the Argo CD and Istio control planes outside ambient mode, applies the public/private ownership roots in dependency order, and never serializes credential values into process arguments.

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`
- `source ./bin/activate-hermit && ./scripts/validate.sh`
- Live reset, install, cluster, router, and remote-host mutations require explicit current-session authorization. The 2026-08-09, 2026-08-14, and 2026-08-17 inspections were explicitly read-only and changed no cluster resource.

## Blockers

- Both GitOps roots now resolve merged `main` paths and the infrastructure boundary remains healthy, but final acceptance exposed source-level Istio webhook-defaulting and workload convergence defects. The reviewed public repair must publish before its private counterpart, then Argo CD must reconcile before final Application, storage, workload, ingress, smoke, and residue evidence can be recorded. Do not rerun bootstrap.

## Completion handoff

- Summary: The earlier authorized reset and three-server install preserved the hosts and formed healthy embedded etcd, but the legacy free-form network arguments were not passed to the K3s installer. The offline repair replaces that contract with validated role-owned Pod/Service/DNS and disabled-component arguments, pins explicit Kubernetes node identities, requires the exact pre-CNI `NetworkPluginNotReady` state, and makes Cilium bootstrap independent of pre-existing CNI, DNS, cert-manager, and GitOps. Bootstrap applies a mode-restricted temporary copy that omits only the Hubble `Certificate` and disables Hubble TLS, then verifies Cilium, node readiness, CoreDNS, DNS resolution, and zero Applications/PVCs before removing all temporary resources.
- Files changed: `AGENTS.md`; `ansible/playbooks/bootstrap_network.yaml`; `ansible/roles/operation_guard/`; `ansible/roles/raspberry_pi/files/scripts/setup-boot-volume.sh`; `ansible/roles/k3s_server/defaults/main.yml`; `ansible/roles/k3s_server/tasks/main.yml`; `ansible/roles/k3s_server/tasks/validate_network.yml`; `ansible/roles/k3s_server/templates/`; `ansible/inventory.example.yml`; `tests/ansible_lifecycle/inventory.yml`; `tests/ansible_lifecycle/k3s_network_contract.yml`; `tests/ansible_lifecycle/run-fixtures.sh`; `tests/ansible_lifecycle/run-entrypoints.sh`; `docs/operations-runbook.md`; `skills/k3s-lifecycle/SKILL.md`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private inventory, renderer, validation, Cilium source/artifact, topology documentation, and global cross-repository knowledge reference.
- Kernel-phase files changed: `ansible/roles/raspi_kernel/defaults/main.yml`; `ansible/roles/raspi_kernel/tasks/main.yml`. The role now distinguishes `/boot` kernel artifacts from `/boot/firmware` capacity, accepts an already-active pinned kernel for safe resume, and skips capacity/install/reboot work only when exact pinned packages and the target kernel are already active.
- Observed verification: The prior authorized reset/install completed with `0` failed and `0` unreachable hosts and produced three unique healthy `v3.6.12` voting members at K3s `v1.36.2+k3s1`; later inspection proved the installed unit omitted the intended network arguments, so that live result is not accepted as the clean-cluster network state. After the offline repair and public sanitization, `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`, `./scripts/validate.sh`, and `./scripts/validate-repository-graph.sh ../homelab-private` all passed. A repository-wide search found no production cluster identity, workstation absolute path, production node identity, or private address range in the public repository. Private rendering and `make validate` also passed. No live cluster, router, or remote-host mutation was performed during this repair.
- Kernel-phase evidence: the exact `ACTIVATE KERNEL 5.15.0-1105-raspi ON <cluster-id>` authorization was recorded for the private production identity. The guarded serial play completed with every node at `ok=25 changed=0 unreachable=0 failed=0`; all exact package, active-kernel, retained-fallback, boot-file, package-integrity, and K3s-absence assertions passed. Independent strict-SSH checks returned all three inventory-declared hosts on `5.15.0-1105-raspi`, found both target and fallback boot files, and confirmed K3s paths/service absent. Every API port was closed and the controller kubeconfig remained absent. Post-phase `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, `./scripts/validate-repository-graph.sh ../homelab-private`, and private `make validate` passed.
- Install-phase evidence: the exact `INSTALL K3S v1.36.2+k3s1 ON <cluster-id>` authorization was recorded for the private production identity. The guarded serial install ended with each node at `unreachable=0 failed=0`, validated the installer and ARM64 binary checksums, and exported a mode-`0600` controller kubeconfig. Embedded etcd reported three unique healthy voting non-learners at the required version, one leader, and two active peers from every member. Independent unit inspection found the inventory-declared Pod, Service, and DNS network values and all five required disabled components on every server; joiners use a root-owned mode-`0600` token file and no legacy environment file remains. Kubernetes reported exactly the three inventory-declared nodes at `v1.36.2+k3s1`, each NotReady solely with `NetworkPluginNotReady`, using distinct Pod subnets within the declared cluster CIDR. There were zero PVCs, no Argo CD Application CRD, and no daemonsets before Cilium.
- Network-phase evidence: the exact `BOOTSTRAP NETWORK <cluster-id>` authorization was recorded for the private production identity. The first invocation used a relative private-artifact path and stopped during preflight before apply; the absolute-path retry proved the public/private artifact substitution boundary, created mode-restricted temporary copies, omitted the Hubble Certificate, changed only `hubble-disable-tls` to `"true"`, applied Cilium v1.20.0, rolled out both daemonsets and both operator replicas, made every exact node Ready, and removed the controller artifact. Its final `cilium-dbg status --brief` check expected obsolete verbose strings even though every agent returned exit zero and exact output `OK`; `ansible/playbooks/bootstrap_network.yaml` now validates that current contract and `./scripts/validate-ansible.sh` passes. Independent post-apply checks returned `OK` from all three Cilium agents, successful Cilium/Envoy/operator/CoreDNS rollouts, and all inventory-declared nodes Ready on the expected Pod subnets. A temporary immutable BusyBox probe resolved the Kubernetes service through the declared cluster DNS, then was deleted and proved absent. PVC count remains zero, the Argo Application CRD remains absent, Hubble TLS is temporarily disabled, and no cert-manager API exists.
- Bootstrap entrypoint evidence: the released `homelab kubeconfig` command still validates and securely exports the mode-`0600` controller file. GitOps bootstrap is now the repository-owned `scripts/bootstrap.sh`; it validates explicit repository and kubeconfig paths, keeps credentials out of process arguments, and accepts no authorization or cluster-ID flag.
- Read-only bootstrap-failure evidence from 2026-08-09: the external API readiness check and all three `v1.36.2+k3s1` nodes passed; Cilium and Cilium Envoy were `3/3` Ready, both Cilium operators and CoreDNS were available, and all APIServices were available. The public root at source revision `14c5e705dda00234a3d8afbc304e1be1cc873c4b` created 14 child Applications at once. `cluster-namespaces` became Healthy/Synced and labeled the Argo CD namespace for ambient mode while `istiod` remained Missing and `ztunnel` remained `0/3` Ready because `istio-ca-root-cert` did not exist. Argo application-controller logs then continuously reported `connect: connection refused` to `10.50.0.1:443`; repo-server and server entered CrashLoopBackOff; no Application reconciled after approximately `04:16Z`. Longhorn managers were `0/3` Ready, Grafana lacked its private credential Secret, the ingress gateway retained the unresolved `auto` image, no PVC existed, the private `cilium`, `homelab-private`, and `homelab-bootstrap` Applications were absent, `hubble-disable-tls` remained `"true"`, and `Certificate/hubble-server-certs` remained absent. The 1Password Connect Deployment, ClusterSecretStore, and GitHub App ExternalSecret were healthy, but the rendered Helm test Pod ran before Connect was ready, failed once, and leaves that Application Progressing.
- During the same read-only session, a later snapshot found `DaemonSet/ztunnel` and its Pods absent even though the stale `istio-ztunnel` Application status still reported the DaemonSet Synced and the Application Progressing. The inspecting agent issued no mutation. This unobserved external state change further proves Argo reconciliation is not authoritative while its controller lacks API connectivity.
- Offline public `make validate` still passed (`51` Ansible files; `349` rendered resources, `245` valid, `0` invalid, `0` errors, `104` schema-skipped) but emitted `<unknown>:1: SyntaxWarning: invalid decimal literal` before the Ansible summary. A targeted search found no matching unquoted version/address condition. Locate this warning before accepting the bootstrap fix; it was not implicated in the observed live ambient-network failure.
- Offline bootstrap-repair evidence: `scripts/bootstrap.sh` has a credential-free dry-run, protected kubeconfig preflight, staged Istio-before-Argo application and rollout gates, optional `--force-conflicts` forwarding to every server-side apply, and a clean handoff after creating `core-infrastructure-aoa` and `private-aoa`. Cilium is a child of `private-aoa`; the obsolete private ownership root is removed. `scripts/prune.sh --reset` removes direct bootstrap manifests in reverse order after clearing Application finalizers to prevent cascading workload deletion. `tests/bootstrap/run.sh` proves ordering, forced-conflict forwarding, rejection of the removed authorization option, the app-of-apps stopping boundary, mandatory reset, and reverse teardown without cluster contact.
- Remaining live boundary: publish the public revision and then the private revision so both root paths exist on `main`, allow Argo CD to reconcile without rerunning bootstrap, and complete Application, PVC, workload, smoke-test, and residue acceptance. The two ignored Connect input files remain on the controller at corrected mode `0600`.
- Final offline repair validation: public `make validate` passed with `51` Ansible files at zero failures/warnings, lifecycle fixtures passing, bootstrap/prune fixtures passing, and `349` rendered resources (`245` valid, `0` invalid, `0` errors, `104` schema-skipped). Private `make validate` passed task lifecycle, JSON, Markdown-link, and seven-package router-profile checks. `./scripts/validate-repository-graph.sh ../homelab-private` passed. No kubeconfig-backed command or live infrastructure mutation was executed.
- Read-only post-bootstrap inspection on 2026-08-14 found the API ready, three Ready `v1.36.2+k3s1` nodes, fully rolled out Cilium, Cilium Envoy, Istio CNI, `istiod`, ztunnel, and Argo CD, both control-plane namespaces outside ambient mode, and Hubble TLS restored with a Ready Certificate and TLS Secret. The obsolete root Applications were absent. Final acceptance failed: both new roots were `Unknown` with `ComparisonError` because their `main` source paths were not published; only the Grafana workload remained Pending because its credential Secret was absent; zero PVCs, Longhorn volumes, CNPG clusters, MetalLB workloads, Cloudflare Tunnel workloads, LoadBalancer addresses, and Istio routing resources existed. All APIServices were available. The inspection changed no cluster resource. Two ignored Connect input files were found at mode `0644` and restricted locally to `0600` without reading them; they remain controller credential residue pending operator-approved removal.
- Read-only final-acceptance inspection on 2026-08-17 confirmed both replacement roots at merged revisions, the API, three Ready nodes, Cilium, Istio, Argo CD, Hubble TLS, all APIServices, and three Bound PVCs. It isolated controller-defaulted Istio webhook failure policies plus private Grafana, Redis, and database desired-state defects without changing the cluster.
- Convergence-repair validation on 2026-08-17 passed public `make validate` with `51` Ansible files at zero failures/warnings and `351` rendered resources (`246` valid, `0` invalid, `0` errors, `105` schema-skipped), private `make validate`, and the cross-repository graph validator. Focused renders completed; no live cluster mutation occurred.
