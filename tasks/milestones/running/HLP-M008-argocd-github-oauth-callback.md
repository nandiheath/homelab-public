# HLP-M008 — Argo CD GitHub OAuth callback

- Status: ready-for-rollup
- Owner: Main

## Goal

Keep the external GitHub App callback aligned with the dedicated Argo CD root URL and record the dependency beside the connector configuration.

## Tasks

- [x] HLP-025 — Record Argo CD GitHub OAuth callback

## Acceptance criteria

- [x] GitHub accepts the dedicated Argo CD Dex callback URI and the public desired-state source records the exact required callback.

## Verification

- Scenario or command: request GitHub authorization with the dedicated callback and run repository validation.
- Expected observation: GitHub presents the application authorization/login flow instead of rejecting `redirect_uri`, and validation passes.

## Blockers

- None

## Completion handoff

- Tasks rolled up: HLP-025
- Observed milestone verification: GitHub accepted `https://argocd-homelab.nandi.sh/api/dex/callback` for client ID `Iv1.c4bcc7cfd7caf7f0` and presented the `Nandi HomeLab ArgoCD` login flow instead of rejecting `redirect_uri`. The source records the same exact callback, `./scripts/validate.sh` reported 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped, and pull-request checks passed.
- Project status updated: Yes.
- Follow-ups: Remove the rolled-up HLP-025 and HLP-M008 contracts after this evidence merges.
