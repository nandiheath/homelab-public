# Agent task lifecycle

Task IDs use the `HLP` prefix (`homelab-public`): `HLP-NNN`.

## Directories and states

- `planned/` — unclaimed task documents; `Status: planned`.
- `running/` — claimed task documents; `Status: running`.

Use only these statuses: `planned`, `running`, `blocked`, and `ready-for-rollup`.

## Claiming work

A task is claimable only when every dependency has been rolled up and its `Owned paths` do not overlap any document in `running/`. Claim it by moving the identical file from `planned/` to `running/`, setting `Status: running`, and replacing `Owner: unassigned` with exactly one owner.

Each task owns one observable behavior, normally no more than two production paths and focused proof. One implementation agent works in one dedicated worktree per task.

## Completion and rollup

An implementation agent records acceptance-criterion evidence in `Completion handoff`, then changes its status to `ready-for-rollup`. It must not merge, delete the task, update `PROJECT_STATUS.md`, or claim integration validation.

The serial rollup owner merges completed work, runs `./scripts/validate.sh`, updates `PROJECT_STATUS.md` with observed evidence, and removes a successfully rolled-up task file. Keep completed detail in Git history; do not maintain a mutable completed-task index.

## Task template

```markdown
# HLP-NNN — Title

- Status: planned
- Owner: unassigned
- Depends on: none

## Owned paths

## Goal

## Implementation

## Acceptance criteria

## Verification

## Blockers

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
```
