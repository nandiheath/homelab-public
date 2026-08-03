# HLP-009 — Longhorn drain policy

- Status: running
- Owner: LonghornDrainPolicy
- Depends on: none

## Owned paths

- `argocd/infrastructure/longhorn/kustomization.yaml`
- `artifacts/infrastructure/longhorn/`
- `tasks/planned/HLP-009-longhorn-drain-policy.md`

## Goal

Set the explicit Longhorn node-drain policy without adding a backup target or recurring backup job.

## Implementation

Set `defaultSettings.nodeDrainPolicy: block-for-eviction` in public Longhorn desired state and regenerate the committed artifact through the repository renderer.

## Acceptance criteria

- Source and generated output contain `block-for-eviction`.
- No backup target or recurring backup job is introduced.

## Verification

- `. ./bin/activate-hermit && homelab render --path argocd/infrastructure/longhorn --output artifacts/infrastructure/longhorn`
- Validate the rendered Longhorn output.

## Blockers

- None.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
