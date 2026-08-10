# HLP-020 - Add Argo GHCR chart credentials

- Status: running
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

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
