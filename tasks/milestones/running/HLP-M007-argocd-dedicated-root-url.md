# HLP-M007 — Argo CD dedicated root URL

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
- Observed milestone verification: Focused Argo CD renders and `./scripts/validate.sh` passed. The live Argo CD Application reconciled the merged revision, `deployment/argocd-server` rolled out successfully, `argocd-cm` advertises `https://argocd-homelab.nandi.sh`, `server.basehref` is `/`, and `server.rootpath` is empty. The coordinated private route returned HTTP 200 before Cloudflare Access and HTTP 302 to Access after protection was enabled.
- Project status updated: Pending the serial removal commit.
- Delivery: https://github.com/nandiheath/homelab-public/pull/28, https://github.com/nandiheath/homelab-public/pull/32, and https://github.com/nandiheath/homelab-public/pull/36.
- Follow-ups: Complete the private status rollup and portfolio milestone after both repository rollups merge.
