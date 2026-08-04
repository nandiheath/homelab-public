# HLP-M005 — CLI-owned CI rendering

- Status: running
- Owner: Main

## Goal

Make the released `homelab` CLI own changed-source rendering and generated-artifact commits so repository CI needs one render invocation.

## Tasks

- [ ] HLP-023 — Adopt CLI-owned CI rendering

## Acceptance criteria

- [ ] `homelab argocd render --ci` discovers changed direct children under `argocd/infrastructure/` and maps them to `artifacts/infrastructure/`.
- [ ] CI can explicitly request an artifact-only commit and push to the current pull-request branch.
- [ ] The public workflow delegates change detection, rendering, and commit-back behavior to the released CLI.

## Verification

- Scenario or command: exercise source-change, source-deletion, no-change, and commit-and-push behavior against temporary Git repositories, then run `make validate` and the pull-request workflow.
- Expected observation: only affected artifacts change, no-change runs are no-ops, and generated changes are committed and pushed only when explicitly requested.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
