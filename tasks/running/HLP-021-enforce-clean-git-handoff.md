# HLP-021 — Enforce clean Git handoff

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M005
- Depends on: none

## Owned paths

- `skills/contribution-workflow/SKILL.md`
- `tasks/README.md`
- `tasks/TEMPLATE.md`
- `tasks/MILESTONE_TEMPLATE.md`
- `tasks/milestones/running/HLP-M005-agent-git-handoff.md`
- `tasks/running/HLP-021-enforce-clean-git-handoff.md`

## Goal

Require every public-repository session handoff to leave a clean, pushed branch with a reviewable pull request and recorded delivery evidence.

## Implementation

1. Add the shared offline Git handoff check after the existing validation, commit, push, and pull-request steps.
2. Align task templates and lifecycle guidance with the delivery evidence requirement.
3. Prove repository validation and final review-branch publication.

## Acceptance criteria

- [x] Agent and contribution instructions reject successful or blocked handoff with staged, unstaged, or untracked changes.
- [x] Completion handoffs record a commit SHA or pull-request URL.
- [x] Offline validation passes without remote infrastructure or credentials.

## Verification

- `make validate` — passes without live infrastructure access.
- `/Users/nandi/workspace/agent-workspace/bin/agent-workspace repo-handoff validate --root . --pr <URL>` — accepts the final clean, pushed review branch.

## Blockers

- None

## Completion handoff

- Summary: Added the shared offline clean-tree/published-branch gate to the mandatory contribution workflow and aligned public task and milestone handoffs with pull-request delivery evidence.
- Files changed: `skills/contribution-workflow/SKILL.md`, `tasks/README.md`, both task templates, and this task/milestone contract.
- Observed verification: the lifecycle validator passed. After installing the pinned local `ansible.posix` collection, `make validate` passed Ansible lint/syntax, lifecycle fixtures, entrypoint fixtures, and manifest validation with 349 resources, 245 valid, 0 invalid, 0 errors, and 104 schema-skipped; no infrastructure or credentials were contacted.
- Delivery: https://github.com/nandiheath/homelab-public/pull/15
- Follow-ups: Merge the review branch, then let the serial rollup owner check off HLP-021 and remove HLP-M005/HLP-021 after milestone-level verification.
