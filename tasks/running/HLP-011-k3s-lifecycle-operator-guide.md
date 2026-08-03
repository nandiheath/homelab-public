# HLP-011 — K3s lifecycle operator guide

- Status: running
- Owner: Main
- Depends on: HLP-010

## Owned paths

- `skills/k3s-lifecycle/SKILL.md`
- `docs/operations-runbook.md`
- `tasks/planned/HLP-011-k3s-lifecycle-operator-guide.md`

## Goal

Document the exact approved backup-free rebuild procedure, stop conditions, and repair-forward failure path.

## Implementation

Replace upgrade safety placeholders with exact authorizations, preflight, reset, kernel, install/network, bridge/final upgrade, GitOps ordering, acceptance checks, and no-backup boundaries. Specify fail-closed conditions, node-cordon behavior, quorum failure reset/reinstall source boundaries, and prohibit downgrade or restore. Keep HLP-012 as the explicit deferred backup/DR investigation.

## Acceptance criteria

- The guide contains exact command sequence and every live checkpoint.
- It states the destructive scope, no-backup decision, stop conditions, and repair-forward semantics.
- It does not authorize NAS configuration, snapshot creation, restore, or downgrade.

## Verification

- Validate Markdown links and lifecycle task references.

## Blockers

- HLP-010 must be rolled up.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
