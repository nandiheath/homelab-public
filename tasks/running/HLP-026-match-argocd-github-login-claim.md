# HLP-026 — Match Argo CD GitHub login claim

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M009
- Depends on: none

## Owned paths

- `argocd/infrastructure/argocd/values.yaml`
- `artifacts/infrastructure/argocd/configmap_argocd-rbac-cm.yml`
- `PROJECT_STATUS.md`
- `tasks/running/HLP-026-match-argocd-github-login-claim.md`
- `tasks/milestones/running/HLP-M009-argocd-github-rbac.md`

## Goal

Grant the configured GitHub administrator access by evaluating the stable connector claim that carries the GitHub login.

## Implementation

1. Add `preferred_username` to the claims Argo CD evaluates for RBAC.
2. Preserve the existing configured GitHub login mapping and empty default role.
3. Regenerate the committed Argo CD artifact.

## Acceptance criteria

- [x] Source and artifact evaluate `email` and `preferred_username` for RBAC.
- [x] The configured GitHub login maps to `role:admin` without publishing the private email.
- [x] The authenticated administrator can list applications after reconciliation.
- [x] Public repository validation passes.

## Verification

- `homelab argocd render --path argocd/infrastructure/argocd --output artifacts/infrastructure/argocd` — source and artifact converge.
- `./scripts/validate.sh` — public desired state and lifecycle contracts pass.
- Live Argo CD RBAC ConfigMap and authenticated application listing — the login claim is evaluated and applications are visible.

## Blockers

- None

## Completion handoff

- Summary: Added the GitHub `preferred_username` claim to Argo CD RBAC evaluation while preserving the explicit login-to-admin mapping and empty default role.
- Files changed: `argocd/infrastructure/argocd/values.yaml`, `artifacts/infrastructure/argocd/configmap_argocd-rbac-cm.yml`, and this task contract.
- Observed verification: Focused render and `./scripts/validate.sh` passed with 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped. Argo CD reconciled merged revision `2304e881932d096afaa46ef20388f3458d4a8cf1` Healthy/Synced; the live ConfigMap maps `nandiheath` to `role:admin` with scopes `[email, preferred_username]`; after reauthentication, the configured administrator observed the application list.
- Follow-ups: HLP-M009 records criterion-level evidence and is ready for serial rollup.
