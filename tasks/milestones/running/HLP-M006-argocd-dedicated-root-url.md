# HLP-M006 — Argo CD dedicated root URL

- Status: running
- Owner: Main

## Goal

Make the reusable Argo CD installation serve from a dedicated hostname root instead of the legacy shared-host subpath.

## Tasks

- [ ] HLP-024 — Update Argo CD root URL

## Acceptance criteria

- [ ] Argo CD advertises the dedicated root URL.
- [ ] The server no longer requires the legacy subpath.
- [ ] Source and committed render are synchronized.

## Verification

- Scenario or command: render the Argo CD unit and run the repository validator.
- Expected observation: the generated ConfigMaps contain the dedicated root URL and default root serving, with no legacy subpath configuration.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Delivery:
- Follow-ups:
