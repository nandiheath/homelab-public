# Agent milestone and task lifecycle

Task IDs use `HLP-NNN`; milestone IDs use `HLP-MNNN`.

## Directories and state

- `milestones/planned/` — future or newly planned milestone contracts; `Status: planned`.
- `milestones/running/` — active milestone contracts; status `running`, `blocked`, or `ready-for-rollup`.
- `planned/` — unclaimed child tasks; `Status: planned`.
- `running/` — claimed child tasks; status `running`, `blocked`, or `ready-for-rollup`.

Completed contracts are removed after serial rollup. Git history and `PROJECT_STATUS.md` retain completed detail; do not add a `done/` directory or central completed index.

## Milestone-first planning

1. Copy `MILESTONE_TEMPLATE.md` into `milestones/planned/HLP-MNNN-<slug>.md` and define one coherent outcome, its full child-task checklist, acceptance criteria, and milestone-level verification.
2. Copy `TEMPLATE.md` for every child task. Set `Milestone: HLP-MNNN` and list the task in the milestone.
3. A future milestone reminder may remain planned without child tasks until its planning pass starts.
4. Before the first child claim, move the milestone to `milestones/running/`, set `Status: running`, and record one milestone owner.

A child task is claimable only when every dependency has been rolled up and its `Owned paths` do not overlap any running task. Move the identical file from `planned/` to `running/`, set `Status: running`, and record exactly one owner. Use one implementation agent and one dedicated worktree per task.

## Completion and verification

Implementation agents run focused proof, record criterion-level evidence in their task handoff, commit only owned changes, push the exact commit, and record the pull-request URL in `Delivery`. Blocked work uses a draft pull request; a dirty working tree is never a handoff. The serial rollup owner integrates child tasks one at a time and checks them off in the milestone.

A milestone becomes `ready-for-rollup` only when every child task is rolled up and checked, no planned/running child still references it, every milestone acceptance criterion is observed, the milestone's own verification passes, and delivery evidence is recorded. The rollup owner runs `./scripts/validate.sh`, updates `PROJECT_STATUS.md`, and removes the completed milestone.

Validate lifecycle structure locally with `agent-workspace repo-tasks validate --root .`. After publishing a review branch, validate the Git boundary with `agent-workspace repo-handoff validate --root . --pr <URL>`.
