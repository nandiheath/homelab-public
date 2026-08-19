# HLP-M009 — Argo CD GitHub RBAC

- Status: ready-for-rollup
- Owner: Main

## Goal

Make the configured GitHub administrator claim match Argo CD RBAC without exposing the private email identity.

## Tasks

- [x] HLP-026 — Match Argo CD GitHub login claim

## Acceptance criteria

- [x] Argo CD evaluates the GitHub `preferred_username` claim and grants the configured GitHub login `role:admin`.
- [x] The authenticated administrator can see Argo CD applications.

## Verification

- Scenario or command: render and validate desired state, reconcile Argo CD, and repeat the authenticated application listing.
- Expected observation: source and artifact agree, the live RBAC ConfigMap evaluates `preferred_username`, and the configured administrator can list applications.

## Blockers

- None

## Completion handoff

- Tasks rolled up: HLP-026
- Observed milestone verification: Source and artifact evaluate `[email, preferred_username]` while preserving the explicit `nandiheath` administrator mapping and empty default role. Validation and implementation pull-request checks passed. Live Argo CD reconciled revision `2304e881932d096afaa46ef20388f3458d4a8cf1` Healthy/Synced with the expected RBAC ConfigMap, and the authenticated administrator confirmed applications are visible after reauthentication.
- Project status updated: Pending the serial removal commit.
- Follow-ups: Remove the rolled-up HLP-026 and HLP-M009 contracts after this evidence merges.
