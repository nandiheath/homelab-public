# HLP-M006 — Argo CD dedicated root URL

- Status: ready-for-rollup
- Owner: Main

## Goal

Make the reusable Argo CD installation serve from a dedicated hostname root instead of the legacy shared-host subpath.

## Tasks

- [x] HLP-024 — Update Argo CD root URL

## Acceptance criteria

- [x] Argo CD advertises the dedicated root URL.
- [x] The server no longer requires the legacy subpath.
- [x] Source and committed render are synchronized.

## Verification

- Scenario or command: render the Argo CD unit and run the repository validator.
- Expected observation: the generated ConfigMaps contain the dedicated root URL and default root serving, with no legacy subpath configuration.

## Blockers

- None

## Completion handoff

- Tasks rolled up: HLP-024
- Observed milestone verification: Focused render and `./scripts/validate.sh` passed. The live Argo CD Application reconciled the merged revision, `deployment/argocd-server` rolled out, `argocd-cm` advertises the dedicated root URL, and the command parameters expose `/` as the base reference with an empty root path.
- Project status updated: Pending the serial removal commit.
- Delivery: https://github.com/nandiheath/homelab-public/pull/28 and https://github.com/nandiheath/homelab-public/pull/29
- Follow-ups: Complete private edge-route acceptance and nested-hostname TLS verification under HL-M010.
