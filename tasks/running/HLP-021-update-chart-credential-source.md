# HLP-021 — Update chart credential source

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M005
- Depends on: none

## Owned paths

- `argocd/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`
- `artifacts/infrastructure/bootstrap/externalsecret_ghcr-homelab-services-charts.yml`
- `PROJECT_STATUS.md`
- `tasks/planned/HLP-021-update-chart-credential-source.md`
- `tasks/running/HLP-021-update-chart-credential-source.md`
- `tasks/milestones/planned/HLP-M005-simple-chart-credential-source.md`
- `tasks/milestones/running/HLP-M005-simple-chart-credential-source.md`

## Goal

Change only the Argo OCI credential URL from the repository-prefixed chart package namespace to `ghcr.io/nandiheath/charts` and regenerate the matching artifact.

## Implementation

1. Update the ExternalSecret repository template URL while preserving its resource name, ownership, `type: helm`, OCI enablement, username/password templates, and exact 1Password remote references.
2. Render only `argocd/infrastructure/bootstrap` into its mirrored artifact and confirm no unrelated output drift.
3. Update public status after focused and full offline validation.

## Acceptance criteria

- Source and artifact contain `url: ghcr.io/nandiheath/charts` with otherwise unchanged credential semantics.
- No legacy package prefix remains in current public desired state or status.
- No private AppProject, wildcard source, image pull secret, resolved credential, bootstrap, cluster, Argo CD, secret-resolution, registry-mutation, or deployment operation is added or run.

## Verification

- `homelab argocd render --path argocd/infrastructure/bootstrap --output artifacts/infrastructure/bootstrap` — focused output is regenerated successfully.
- `./scripts/validate.sh` — offline repository validation passes.
- `agent-workspace repo-tasks validate --root .` and exact source/artifact inspection — task lifecycle and credential boundary pass.

## Blockers

- None

## Completion handoff

- Summary: Changed only the ExternalSecret-backed Argo OCI repository URL to the concise `ghcr.io/nandiheath/charts` prefix and regenerated the bootstrap artifact.
- Files changed: `argocd/infrastructure/bootstrap/externalsecret-ghcr-charts.yaml`; `artifacts/infrastructure/bootstrap/externalsecret_ghcr-homelab-services-charts.yml`; `PROJECT_STATUS.md`; this task and its running milestone contract.
- Observed verification: Focused bootstrap rendering completed; `./scripts/validate.sh` reported 350 resources, 245 valid, 0 invalid, 0 errors, and 105 skipped; repository task validation and `git diff --check` passed; exact diff inspection showed only the URL changed in source and artifact; no legacy package prefix remains in `argocd/`, `artifacts/`, or `PROJECT_STATUS.md`.
- Follow-ups: Serially roll up HLP-021/HLP-M005 after review, restore the temporarily yielded HLP-005 bootstrap ownership, and do not apply or resolve the credential as part of this task.
