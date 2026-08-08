# HLP-M003 — Guarded cluster lifecycle

- Status: running
- Owner: Main

## Goal

Deliver the fail-closed three-server K3s rebuild lifecycle, its numbered operator guide, and observed end-to-end final desired-state acceptance without publishing private topology or credentials.

## Tasks

- [ ] HLP-005 — Clean latest-minor cluster rebuild
- [x] HLP-020 — Numbered cluster bootstrap guide
- [x] HLP-021 — Install pinned Ansible collections in CI

## Acceptance criteria

- [x] Offline lifecycle, rendered manifests, and public/private repository graph pass their authoritative validation.
- [x] Numbered documentation distinguishes initial bootstrap, destructive rebuild, final acceptance, and currently disabled upgrades, including every temporary unsafe boundary.
- [ ] The live cluster reaches final GitOps-owned desired state with Hubble TLS restored, expected Applications and PVCs healthy, smoke checks clean, and no credential residue.

## Verification

- Scenario or command: `./scripts/validate-ansible.sh && ./scripts/validate.sh && ./scripts/validate-repository-graph.sh ../homelab-private`
- Expected observation: lifecycle fixtures and entrypoints pass, rendered resources are valid, and no private production value enters public tracked content.
- Scenario or command: HLP-005 final read-only acceptance procedure after separately authorized GitOps bootstrap.
- Expected observation: all final applications, storage, networking, TLS, and residue criteria pass.

## Blockers

- Offline kubeconfig/bootstrap CLI integration is active. Live GitOps bootstrap still requires a fresh exact authorization after the CLI is released and pinned.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
