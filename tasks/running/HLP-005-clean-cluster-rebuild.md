# HLP-005 - Clean latest-minor cluster rebuild

- Status: running
- Owner: Main
- Depends on: HLP-004

## Owned paths
- `AGENTS.md`
- `ansible/roles/operation_guard/`
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
- `docs/operations-runbook.md`
- `skills/k3s-lifecycle/SKILL.md`
- `tasks/running/HLP-005-clean-cluster-rebuild.md`

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

## Verification

- `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`
- `source ./bin/activate-hermit && ./scripts/validate.sh`
- Live reset, install, cluster, router, and remote-host operations require explicit current-session authorization. No authorization has been supplied for another reset/reinstall or for Cilium bootstrap.

## Blockers

- The live K3s installation remains nonconforming: it has default Flannel, kube-proxy, Traefik, ServiceLB, the default Pod CIDR, and a Service CIDR that overlaps the physical LAN. The offline install/Cilium correction and fixtures now validate successfully, but another reset/reinstall and Cilium bootstrap require fresh phase-specific current-session authorizations.

## Completion handoff

- Summary: The earlier authorized reset and three-server install preserved the hosts and formed healthy embedded etcd, but the legacy free-form network arguments were not passed to the K3s installer. The offline repair replaces that contract with validated role-owned Pod/Service/DNS and disabled-component arguments, pins explicit Kubernetes node identities, requires the exact pre-CNI `NetworkPluginNotReady` state, and makes Cilium bootstrap independent of pre-existing CNI, DNS, cert-manager, and GitOps. Bootstrap applies a mode-restricted temporary copy that omits only the Hubble `Certificate` and disables Hubble TLS, then verifies Cilium, node readiness, CoreDNS, DNS resolution, and zero Applications/PVCs before removing all temporary resources.
- Files changed: `AGENTS.md`; `ansible/playbooks/bootstrap_network.yaml`; `ansible/roles/operation_guard/`; `ansible/roles/raspberry_pi/files/scripts/setup-boot-volume.sh`; `ansible/roles/k3s_server/defaults/main.yml`; `ansible/roles/k3s_server/tasks/main.yml`; `ansible/roles/k3s_server/tasks/validate_network.yml`; `ansible/roles/k3s_server/templates/`; `ansible/inventory.example.yml`; `tests/ansible_lifecycle/inventory.yml`; `tests/ansible_lifecycle/k3s_network_contract.yml`; `tests/ansible_lifecycle/run-fixtures.sh`; `tests/ansible_lifecycle/run-entrypoints.sh`; `docs/operations-runbook.md`; `skills/k3s-lifecycle/SKILL.md`; `tasks/running/HLP-005-clean-cluster-rebuild.md`; private inventory, renderer, validation, Cilium source/artifact, topology documentation, and global cross-repository knowledge reference.
- Observed verification: The prior authorized reset/install completed with `0` failed and `0` unreachable hosts and produced three unique healthy `v3.6.12` voting members at K3s `v1.36.2+k3s1`; later inspection proved the installed unit omitted the intended network arguments, so that live result is not accepted as the clean-cluster network state. After the offline repair and public sanitization, `source ./bin/activate-hermit && ./scripts/validate-ansible.sh`, `./scripts/validate.sh`, and `./scripts/validate-repository-graph.sh ../homelab-private` all passed. A repository-wide search found no production cluster identity, workstation absolute path, production node identity, or private address range in the public repository. Private rendering and `make validate` also passed. No live cluster, router, or remote-host mutation was performed during this repair.
- Follow-ups: Obtain a fresh exact reset confirmation and rebuild the live cluster with the corrected installer contract. Then obtain the separate network-bootstrap confirmation and prove private Cilium acceptance, followed by the separate GitOps confirmation and final Applications, PVCs, smoke-test, and credential-residue criteria.
