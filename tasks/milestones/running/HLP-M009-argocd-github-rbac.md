# HLP-M009 — Argo CD GitHub RBAC

- Status: running
- Owner: Main

## Goal

Make the configured GitHub administrator claim match Argo CD RBAC without exposing the private email identity.

## Tasks

- [ ] HLP-026 — Match Argo CD GitHub login claim

## Acceptance criteria

- [ ] Argo CD evaluates the GitHub `preferred_username` claim and grants the configured GitHub login `role:admin`.
- [ ] The authenticated administrator can see Argo CD applications.

## Verification

- Scenario or command: render and validate desired state, reconcile Argo CD, and repeat the authenticated application listing.
- Expected observation: source and artifact agree, the live RBAC ConfigMap evaluates `preferred_username`, and the configured administrator can list applications.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
