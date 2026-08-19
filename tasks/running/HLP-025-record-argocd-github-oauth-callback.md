# HLP-025 — Record Argo CD GitHub OAuth callback

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M008
- Depends on: none

## Owned paths

- `argocd/infrastructure/argocd/values.yaml`
- `PROJECT_STATUS.md`
- `tasks/running/HLP-025-record-argocd-github-oauth-callback.md`
- `tasks/milestones/running/HLP-M008-argocd-github-oauth-callback.md`

## Goal

Record the exact GitHub App callback required by the dedicated Argo CD root URL after correcting the live app registration.

## Implementation

1. Document the exact callback beside the Argo CD GitHub connector.
2. Record the corrected external registration and observed authorization response in project status.

## Acceptance criteria

- [x] The connector source identifies `https://argocd-homelab.nandi.sh/api/dex/callback` as the required GitHub App callback.
- [x] GitHub accepts that callback for client ID `Iv1.c4bcc7cfd7caf7f0`.
- [x] Public repository validation passes.

## Verification

- `./scripts/validate.sh` — source and rendered desired state remain valid.
- Request the GitHub authorization URL — GitHub presents the `Nandi HomeLab ArgoCD` login/authorization flow rather than a callback mismatch.

## Blockers

- None

## Completion handoff

- Summary: Recorded and corrected the exact GitHub App callback required by the dedicated Argo CD URL.
- Files changed: `argocd/infrastructure/argocd/values.yaml`, `PROJECT_STATUS.md`, and this task contract.
- Observed verification: GitHub redirected the exact authorization request to its login flow for `Nandi HomeLab ArgoCD` instead of returning the `redirect_uri` mismatch. `./scripts/validate.sh` reported 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped.
- Follow-ups: Serially roll up HLP-M008 after this task merges.
