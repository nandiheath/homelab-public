# HLP-026 — Match Argo CD GitHub login claim

- Status: running
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
- [ ] The authenticated administrator can list applications after reconciliation.
- [x] Public repository validation passes.

## Verification

- `homelab argocd render --path argocd/infrastructure/argocd --output artifacts/infrastructure/argocd` — source and artifact converge.
- `./scripts/validate.sh` — public desired state and lifecycle contracts pass.
- Live Argo CD RBAC ConfigMap and authenticated application listing — the login claim is evaluated and applications are visible.

## Blockers

- None

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
