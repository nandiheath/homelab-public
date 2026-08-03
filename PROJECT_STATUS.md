# Project status

_Last observed: 2026-08-03_

## Current state

- Public GitOps desired state lives in `argocd/infrastructure/`; committed render output lives in `artifacts/infrastructure/`.
- The repository contains Ansible playbooks for host operations and a Kubernetes bootstrap script. They are operational surfaces, not routine validation.
- Offline K3s lifecycle implementation and operator guidance are rolled up. HLP-012 remains planned and unclaimed for future backup/DR design; live lifecycle execution is blocked on verified private SSH host-key pins.

## Observed validation

- `./scripts/validate.sh` completed successfully on 2026-08-02: shell and workflow linting passed; the infrastructure renderer completed; kubeconform reported 350 resources, 243 valid, 0 invalid, 0 errors, and 107 skipped schemas.
- GitHub Actions runs the same command in `.github/workflows/render.yaml` with read-only repository permissions and no deployment step.
- K3s installs now export a controller-local, mode-restricted kubeconfig only after the first server API is ready; `fetch_kubeconfig.yaml` reuses that export path and reset removes it once. Static lint and syntax checks, plus GitHub Actions rendering validation, passed on 2026-08-03. Live recovery evidence remains private and is not recorded in this public repository.
- Public lifecycle foundations now fail closed on host-key checking, cluster/version inventory shape, exact operation confirmations, controller-tool versions, and sensitive controller file permissions. `./scripts/validate.sh` passed on 2026-08-03 (350 resources; 243 valid; 0 invalid; 0 errors).
- Longhorn desired state and committed render now set `defaultSettings.nodeDrainPolicy: block-for-eviction`; no backup target or recurring backup policy was introduced.
- Cluster-health and maintenance roles passed `ansible-lint` (production profile) and the repository validation suite on 2026-08-03. Fixture coverage remains a required HLP-010 gate before live lifecycle use.
- Reset, pinned Raspberry Pi kernel maintenance, and clean K3s install playbooks/roles passed their focused production-profile `ansible-lint` checks and `./scripts/validate.sh` on 2026-08-03. They remain offline-only until HLP-010 fixture coverage and verified production SSH host-key pins exist.
- The guarded two-step K3s bridge upgrade passed focused production-profile `ansible-lint` and repository validation on 2026-08-03; exact source/target fixture coverage remains an HLP-010 requirement before any live upgrade.
- Controller-local private Cilium bootstrap and Argo private-source targeting passed focused Ansible lint and repository rendering validation on 2026-08-03; live application remains blocked on verified SSH host-key pins and final fixture coverage.
- Controller-only GitOps bootstrap passed focused Ansible lint and repository rendering validation on 2026-08-03; it has no installation import and removes controller-temporary credentials in an `always` block.
- `./scripts/validate-ansible.sh` passed on 2026-08-03 with exact Ansible Core 2.21.2 and ansible-lint 26.6.0: 48 files linted with zero failures/warnings, every lifecycle playbook syntax-checked, and the offline authorization matrix rejected missing, boolean, stale-cluster, wrong-confirmation, and invalid bridge cases before its mutation sentinel.
- The exact backup-free lifecycle runbook and `k3s-lifecycle` skill replaced all operational placeholders on 2026-08-03. A final `./scripts/validate-ansible.sh` and `./scripts/validate.sh` rerun passed after the documentation cutover.

- HLP-013 through HLP-018 lifecycle corrections are integrated and ready for serial rollup: kernel activation, clean install membership, bridge upgrades, reset preservation, controller bootstrap, and actual-entrypoint fixture coverage. Focused Ansible validation passed on 2026-08-03 with no live host or cluster contact.

- Latest platform contract now targets direct K3s `v1.36.2+k3s1` with embedded etcd `v3.6.12-k3s1`, official installer and ARM64 checksums, and immutable Cilium `v1.20.0` images compatible with Kubernetes 1.36. `./scripts/validate-ansible.sh`, `./scripts/validate.sh`, offline lifecycle fixtures, and Cilium rendering passed on 2026-08-03 without live infrastructure contact.

## Rollup protocol

Only the serial rollup owner integrates ready tasks, runs repository validation, updates this file, and removes rolled-up task documents. See `AGENTS.md` and `tasks/README.md`.

## Known follow-ups

- Cross-repository graph validation is available via `scripts/validate-repository-graph.sh`, but was not run because it requires an explicit path to the private repository and its denylist.
