# HLP-024 — Update Argo CD root URL

- Status: ready-for-rollup
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

- [x] The Argo CD ConfigMap advertises the dedicated root URL.
- [x] The command-parameters ConfigMap uses default root serving with no legacy subpath.
- [x] Source and committed artifact render without drift.

## Verification

- `homelab argocd render --path argocd/infrastructure/argocd --output artifacts/infrastructure/argocd` — source and artifact converge.
- `./scripts/validate.sh` — public repository validation passes.

## Blockers

- None

## Completion handoff

- Summary: Moved Argo CD from the shared-host subpath to the dedicated hostname root and regenerated all checksum-dependent artifacts.
- Files changed: `argocd/infrastructure/argocd/values.yaml`, `artifacts/infrastructure/argocd/`.
- Observed verification: Focused rendering completed without error. `./scripts/validate.sh` reported 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped. Pull-request checks passed. Live Argo CD reconciliation reached `Synced` and `Healthy`; `argocd-cm` advertises the dedicated root URL, `server.basehref` is `/`, `server.rootpath` is empty, and `deployment/argocd-server` rolled out successfully.
- Delivery: https://github.com/nandiheath/homelab-public/pull/28 merged as `353064f2e16d4e3ffc36248b0eea162bdf96557b`.
- Follow-ups: Complete private edge-route acceptance and nested-hostname TLS verification under HL-M010.
