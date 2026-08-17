# Project status

_Last observed: 2026-08-09_

## Current state

- Public GitOps desired state is discovered recursively below `argocd/`; committed render output mirrors each source-relative path below `artifacts/`. Reusable infrastructure remains public and applications remain private.
- The repository contains Ansible playbooks for host operations and a Kubernetes bootstrap script. They are operational surfaces, not routine validation.
- HLP-005 remains active and blocked at its separately authorized final GitOps acceptance boundary.
- HLP-M002 remains a future backup/disaster-recovery planning reminder; it carries no implementation claim and is not evidence of deployed backup infrastructure.
- Planning is milestone-first: every child task references a parent, and milestone completion requires child rollup plus milestone-level verification.
- Argo CD bootstrap desired state includes a separate ExternalSecret-backed repository credential for authenticated read-only OCI Helm access to `ghcr.io/nandiheath/charts`. It resolves only `username` and `token` from the existing 1Password ClusterSecretStore, emits no resolved credential or image pull secret, and is paired with an exact private AppProject source allowlist.
- Argo CD desired state now serves from the root of `https://argocd.homelab.nandi.sh`; the legacy shared-host base-reference and root-path overrides are removed.

## Observed validation

- `./scripts/validate.sh` completed successfully on 2026-08-02: shell and workflow linting passed; the infrastructure renderer completed; kubeconform reported 350 resources, 243 valid, 0 invalid, 0 errors, and 107 skipped schemas.
- The milestone-task lifecycle rollout passed `agent-workspace repo-tasks validate --root .` and the full offline repository validator on 2026-08-02.
- GitHub Actions validates without deployment credentials or infrastructure mutation. Pull-request runs never push. Trusted branch runs validate before artifact-only commit-back, dispatch validation for the generated commit, and fail the original source-only revision.
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
- Released `homelab-0.5.0` is the sole public/private manifest renderer, guarded cluster bootstrap CLI, and private OpenWrt command entrypoint. It adds stable or explicit direct-node kubeconfig export and guarded GitOps bootstrap while retaining recursive native Helm/Kustomize rendering and the reviewed router operations.
- The shared renderer migration passed all three CLI package tests, the complete public Ansible/manifest validator, two byte-identical public renders (`352` files; SHA-256 tree digest `d245985e0ceff210e1e700fb0fe0a58148a76417d146a1aa70a7edf6d1b10e09`), and public/private repository graph validation. GitHub pull-request validation passed twice without generated drift.
- HLP-M004 completed on 2026-08-09. A focused bootstrap render and `./scripts/validate.sh` reported 350 resources, 245 valid, 0 invalid, 0 errors, and 105 schema-skipped; repository task validation passed. Source/artifact inspection confirmed `type: helm`, the exact GHCR URL, `enableOCI: "true"`, repository-secret labeling, unresolved username/password templates, and the exact `ghcr-chart-read-credentials` remote refs. The public artifact contains no private AppProject, GHCR wildcard, image pull secret, or resolved credential; private revision `fbb2fe825393b1254a0ab19add210dd66b2e5d25` contains only the private GitOps repository and exact chart repository in its AppProject allowlist. No bootstrap, apply, cluster, Argo CD, secret-resolution, registry-mutation, or deployment command ran.
- HLP-M005 completed on 2026-08-09. Source and committed artifact use `ghcr.io/nandiheath/charts`, retain `type: helm`, `enableOCI: "true"`, repository-secret labeling, unresolved username/password templates, and the exact `ghcr-chart-read-credentials` remote references. A focused bootstrap render and `./scripts/validate.sh` reported 350 resources, 245 valid, 0 invalid, 0 errors, and 105 schema-skipped; repository task validation and exact boundary inspection passed. The legacy package prefix is absent from current public desired state and status. No private AppProject, wildcard source, image pull secret, resolved credential, bootstrap, cluster, Argo CD, secret-resolution, registry mutation, or deployment operation was added or run. Bootstrap source and artifact ownership returned to blocked HLP-005.
- HLP-M006 completed on 2026-08-17. Focused rendering and `./scripts/validate.sh` passed with 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped. The live Argo CD Application reconciled merged revision `353064f2e16d4e3ffc36248b0eea162bdf96557b`, remained Healthy, rolled out `deployment/argocd-server`, advertised the dedicated root URL, and exposed `/` as its base reference with an empty root path.

## Rollup protocol

Only the serial rollup owner integrates ready tasks, runs repository validation, updates this file, and removes rolled-up task documents. See `AGENTS.md` and `tasks/README.md`.

## Known follow-ups

