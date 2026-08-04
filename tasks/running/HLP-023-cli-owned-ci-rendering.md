# HLP-023 — Adopt CLI-owned CI rendering

- Status: running
- Owner: Main
- Milestone: HLP-M005
- Depends on: none

## Owned paths

- `.github/workflows/render.yaml`
- `Makefile`
- `README.md`
- `bin/hermit.hcl`
- `bin/homelab`
- `bin/.homelab-*.pkg`
- `tasks/planned/HLP-023-cli-owned-ci-rendering.md`
- `tasks/running/HLP-023-cli-owned-ci-rendering.md`
- `tasks/milestones/planned/HLP-M005-ci-render-workflow.md`
- `tasks/milestones/running/HLP-M005-ci-render-workflow.md`
- `PROJECT_STATUS.md`

## Goal

Reduce the public render workflow to the released CLI's CI mode while retaining exact changed-source and artifact-only commit behavior.

## Implementation

1. Pin the released CLI with `--ci` and explicit commit-and-push support, replace workflow-side Git orchestration with one CLI invocation, and update operator documentation.

## Acceptance criteria

- [ ] The workflow contains no custom changed-source loop or Git commit/push script.
- [ ] Source changes and deletions update only their matching artifact directories.
- [ ] No-change and generated-only runs create no additional commit.

## Verification

- `make render && git diff --exit-code -- artifacts/` — full local output remains stable.
- `make validate` — repository validation passes.
- Pull-request source and generated-only workflow runs — the first commits only real artifact drift and the follow-up is a no-op.

## Blockers

- None

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
