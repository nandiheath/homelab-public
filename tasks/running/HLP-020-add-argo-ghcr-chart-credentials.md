# HLP-020 - Add Argo GHCR chart credentials

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M004
- Depends on: none

## Owned paths

- `argocd/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`
- `argocd/infrastructure/bootstrap/kustomization.yaml`
- `artifacts/infrastructure/bootstrap/externalsecret_ghcr-homelab-services-charts.yml`
- `tasks/running/HLP-020-add-argo-ghcr-chart-credentials.md`

## Goal

Prepare least-privilege public desired state for Argo CD to read private Helm charts from GHCR through an ExternalSecret-backed repository Secret, without applying it to the cluster.

## Implementation

Reuse the existing `externalsecret-argocd.yaml` and `ClusterSecretStore/onepassword` pattern. Add a separate Argo repository Secret named `ghcr-homelab-services-charts` in namespace `argocd`, labeled `argocd.argoproj.io/secret-type: repository`, with templated string data for `type: helm`, `url: ghcr.io/nandiheath/homelab-services-charts`, `enableOCI: "true"`, `username`, and `password`. Reference `ghcr-chart-read-credentials` fields `username` and `token` from the existing 1Password-backed store. The private AppProject allowlist remains private desired state and is implemented by the dependent HL-016 task in `homelab-private`; public artifacts must not contain that AppProject. Render the bootstrap unit with the pinned renderer and validate offline.

## Acceptance criteria

- The source and generated artifact contain the ExternalSecret and resulting Argo repository Secret contract without resolved credentials or a Kubernetes imagePullSecret.
- The dependent private HL-016 AppProject allowlist contains the exact private chart repository URL and no broader GHCR wildcard; the public artifact remains free of the private AppProject.
- Focused render, `./scripts/validate.sh`, and repository task validation pass without contacting a cluster, running bootstrap, applying manifests, or printing secrets.

## Verification

- Focused bootstrap render and source/artifact inspection of resource names, labels, ExternalSecret remote refs, templated keys, and the private AppProject allowlist.
- `./scripts/validate.sh`.
- `agent-workspace repo-tasks validate --root .`.

## Blockers

None observed. HLP-005 released the exact bootstrap source and artifact paths when its offline repair landed; its separately authorized live acceptance remains independent.

## Completion handoff

- Summary: Added a separate ExternalSecret-backed Argo repository Secret for authenticated OCI Helm reads from `ghcr.io/nandiheath/homelab-services-charts`, using only the existing 1Password ClusterSecretStore and the `username`/`token` fields of `ghcr-chart-read-credentials`.
- Files changed: `argocd/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`; `argocd/infrastructure/bootstrap/kustomization.yaml`; `artifacts/infrastructure/bootstrap/externalsecret_ghcr-homelab-services-charts.yml`; HLP-005 ownership metadata; and this task handoff.
- Observed verification: The focused bootstrap render completed; `./scripts/validate.sh` reported 350 resources, 245 valid, 0 invalid, 0 errors, and 105 schema-skipped; repository task validation passed. Source/artifact inspection confirmed the repository label, `type: helm`, exact URL, OCI enablement, unresolved username/password templates, and exact 1Password remote refs. Public artifacts contain no private AppProject, GHCR wildcard, imagePullSecret, or resolved credential. Private HL-016 landed at `fbb2fe825393b1254a0ab19add210dd66b2e5d25` with exactly the private GitOps repository and the enrolled GHCR chart repository in `spec.sourceRepos`. No bootstrap, apply, cluster, Argo CD, secret-resolution, registry-mutation, or deployment command ran.
- Follow-ups: The serial rollup owner must complete HLP-M004 milestone verification, update `PROJECT_STATUS.md`, and remove the successful contracts.
