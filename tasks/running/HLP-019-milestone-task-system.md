# HLP-019 — Adopt milestone-based task planning

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M003
- Depends on: none

## Owned paths

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `tasks/`

## Goal

Adopt the canonical milestone-first planning lifecycle while preserving repository-specific safety and rollup rules.

## Implementation

1. Add milestone contracts and require every newly planned task to reference one.
2. Standardize task and milestone templates, including milestone-level acceptance and verification.
3. Backfill claimable work into milestones and add the future backup/recovery milestone reminder.

## Acceptance criteria

- [x] Repository guidance defines milestone-first planning and completion gates.
- [x] New task and milestone templates are present under `tasks/`.
- [x] Claimable tasks reference a milestone.
- [x] A future, unimplemented milestone remains visibly planned.

## Verification

- `./scripts/validate.sh` — repository validation succeeds without cluster access.

## Blockers

- None.

## Completion handoff

- Summary: Added milestone-first planning, templates, child-task references, and rollup gates while preserving repository safety rules.
- Files changed: `AGENTS.md`, `tasks/README.md`, task templates and metadata, and milestone contracts under `tasks/milestones/`.
- Observed verification: `agent-workspace repo-tasks validate --root .` passed; `./scripts/validate.sh` rendered 350 resources with 243 valid, 0 invalid, 0 errors, and 107 skipped schemas.
- Follow-ups: None.
