# HLP-019 — Adopt milestone-based task planning

- Status: planned
- Owner: unassigned
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

- [ ] Repository guidance defines milestone-first planning and completion gates.
- [ ] New task and milestone templates are present under `tasks/`.
- [ ] Claimable tasks reference a milestone.
- [ ] A future, unimplemented milestone remains visibly planned.

## Verification

- `./scripts/validate.sh` — repository validation succeeds without cluster access.

## Blockers

- None.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
