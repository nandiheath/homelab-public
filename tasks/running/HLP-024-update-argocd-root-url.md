# HLP-024 — Update Argo CD root URL

- Status: running
- Owner: Main
- Milestone: HLP-M006
- Depends on: none

## Owned paths

- `argocd/infrastructure/argocd/values.yaml`
- `artifacts/infrastructure/argocd/`
- `tasks/running/HLP-024-update-argocd-root-url.md`

## Goal

Serve Argo CD from the root of its dedicated public hostname and advertise that URL to authentication and notification integrations.

## Implementation

1. Replace the legacy shared-host URL with the dedicated root URL.
2. Remove the legacy base-reference and root-path overrides.
3. Regenerate the committed Argo CD artifact.

## Acceptance criteria

- [ ] The Argo CD ConfigMap advertises the dedicated root URL.
- [ ] The command-parameters ConfigMap uses default root serving with no legacy subpath.
- [ ] Source and committed artifact render without drift.

## Verification

- `homelab argocd render --path argocd/infrastructure/argocd --output artifacts/infrastructure/argocd` — source and artifact converge.
- `./scripts/validate.sh` — public repository validation passes.

## Blockers

- None

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Delivery:
- Follow-ups:
