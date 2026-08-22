# HLP-M008 — CNPG platform safety for Homelab Hub

- Status: running
- Owner: Main

## Goal

Add reviewed CloudNativePG 1.30.0 and Barman Cloud plugin 0.14.0 sources with immutable evidence and offline compatibility validation, without changing PostgreSQL operand images or reconciling a cluster.

## Tasks

- [ ] HLP-026 — Upgrade CNPG and add Barman Cloud plugin sources

## Acceptance criteria

- [ ] CNPG 1.30.0 and plugin 0.14.0 render from exact reviewed immutable sources.
- [ ] Public validation passes with K3s 1.36 and arm64 compatibility evidence recorded without private topology.

## Verification

- Scenario or command: `source bin/activate-hermit && homelab argocd render --all && ./scripts/validate.sh`.
- Expected observation: deterministic rendered output and zero validation failures; no operand image or private credential changes.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
