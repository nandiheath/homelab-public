# HLP-M008 — Argo CD GitHub OAuth callback

- Status: running
- Owner: Main

## Goal

Keep the external GitHub App callback aligned with the dedicated Argo CD root URL and record the dependency beside the connector configuration.

## Tasks

- [ ] HLP-025 — Record Argo CD GitHub OAuth callback

## Acceptance criteria

- [ ] GitHub accepts the dedicated Argo CD Dex callback URI and the public desired-state source records the exact required callback.

## Verification

- Scenario or command: request GitHub authorization with the dedicated callback and run repository validation.
- Expected observation: GitHub presents the application authorization/login flow instead of rejecting `redirect_uri`, and validation passes.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
