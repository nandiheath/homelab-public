# HLP-M005 — Simple chart credential source

- Status: running
- Owner: Main

## Goal

Point the public ExternalSecret-backed Argo OCI repository credential at the concise `ghcr.io/nandiheath/charts` package prefix.

## Tasks

- [ ] HLP-021 — Update chart credential source

## Acceptance criteria

- [ ] Public source and committed artifact use `ghcr.io/nandiheath/charts`, retain `type: helm`, `enableOCI: "true"`, repository-secret labeling, and unresolved least-privilege username/token references.
- [ ] The legacy package prefix is absent from current public desired state and status; no private AppProject, image pull secret, resolved credential, bootstrap, cluster operation, Argo CD call, or deployment is introduced.

## Verification

- Scenario or command: focused bootstrap render, `./scripts/validate.sh`, repository task validation, and source/artifact boundary inspection.
- Expected observation: render and validation pass; source/artifact match exactly; only the concise credential URL changes.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
