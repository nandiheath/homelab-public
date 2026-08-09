# HLP-020 - Add Argo GHCR chart credentials

- Status: planned
- Owner: unassigned
- Milestone: HLP-M004
- Depends on: none

## Owned paths

- `argocd/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`
- `argocd/infrastructure/bootstrap/kustomization.yaml`
- `argocd/infrastructure/bootstrap/projects/homelab-private.yaml`
- `artifacts/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`
- `artifacts/infrastructure/bootstrap/kustomization.yaml`
- `artifacts/infrastructure/bootstrap/projects/homelab-private.yaml`
- `tasks/running/HLP-020-add-argo-ghcr-chart-credentials.md`

## Goal

Prepare least-privilege public desired state for Argo CD to read private Helm charts from GHCR through an ExternalSecret-backed repository Secret, without applying it to the cluster.

## Implementation

Reuse the existing `externalsecret-argocd.yaml` and `ClusterSecretStore/onepassword` pattern. Add a separate Argo repository Secret named `ghcr-homelab-services-charts` in namespace `argocd`, labeled `argocd.argoproj.io/secret-type: repository`, with templated string data for `type: helm`, `url: ghcr.io/nandiheath/homelab-services-charts`, `enableOCI: "true"`, `username`, and `password`. Reference `ghcr-chart-read-credentials` fields `username` and `token` from the existing 1Password-backed store. Add the exact `ghcr.io/nandiheath/homelab-services-charts` source URL to `homelab-private` AppProject `spec.sourceRepos`, render the bootstrap unit with the pinned renderer, and validate offline.

## Acceptance criteria

- The source and generated artifact contain the ExternalSecret and resulting Argo repository Secret contract without resolved credentials or a Kubernetes imagePullSecret.
- The AppProject allowlist contains the exact private chart repository URL and no broader GHCR wildcard.
- Focused render, `./scripts/validate.sh`, and repository task validation pass without contacting a cluster, running bootstrap, applying manifests, or printing secrets.

## Verification

- Focused bootstrap render and source/artifact inspection of resource names, labels, ExternalSecret remote refs, templated keys, and AppProject allowlist.
- `./scripts/validate.sh`.
- `agent-workspace repo-tasks validate --root .`.

## Blockers

None observed.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
