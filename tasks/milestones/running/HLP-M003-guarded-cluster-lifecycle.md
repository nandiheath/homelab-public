# HLP-M003 — Guarded cluster lifecycle

- Status: ready-for-rollup
- Owner: Main

## Goal

Deliver the fail-closed three-server K3s rebuild lifecycle, its numbered operator guide, and observed end-to-end final desired-state acceptance without publishing private topology or credentials.

## Tasks

- [x] HLP-005 — Clean latest-minor cluster rebuild
- [x] HLP-020 — Numbered cluster bootstrap guide
- [x] HLP-021 — Install pinned Ansible collections in CI

## Acceptance criteria

- [x] Offline lifecycle, rendered manifests, and public/private repository graph pass their authoritative validation.
- [x] Numbered documentation distinguishes initial bootstrap, destructive rebuild, final acceptance, and currently disabled upgrades, including every temporary unsafe boundary.
- [x] The live cluster reaches final GitOps-owned desired state with Hubble TLS restored, expected Applications and PVCs healthy, smoke checks clean, and no credential residue.

## Verification

- Scenario or command: `./scripts/validate-ansible.sh && ./scripts/validate.sh && ./scripts/validate-repository-graph.sh ../homelab-private`
- Expected observation: lifecycle fixtures and entrypoints pass, rendered resources are valid, and no private production value enters public tracked content.
- Scenario or command: HLP-005 final read-only acceptance procedure after separately authorized GitOps bootstrap.
- Expected observation: all final applications, storage, networking, TLS, and residue criteria pass.

## Blockers

- None.

## Completion handoff

- Tasks rolled up: HLP-005, HLP-020, and HLP-021.
- Observed milestone verification: Offline lifecycle, fixture, render, sanitization, and cross-repository graph validation passed. Final read-only acceptance observed all API readiness checks passing, three Ready pinned-version nodes, every expected Application Healthy/Synced, every workload controller converged, exactly three reviewed PVCs Bound, Hubble TLS Ready, both control-plane namespaces outside ambient mode, retained ingress routes healthy, the obsolete Prometheus route absent, and no backup policy or bootstrap-temporary credential file.
- Project status updated: Pending final serial rollup commit.
- Follow-ups: Stable external API endpoint and backup/disaster-recovery design remain separate planned work.
