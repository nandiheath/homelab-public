# HLP-M005 — Agent Git handoff discipline

- Status: running
- Owner: Main

## Goal

Make every public-repository agent session finish with verified work committed and published for review instead of left in a dirty checkout.

## Tasks

- [ ] HLP-021 — Enforce clean Git handoff

## Acceptance criteria

- [ ] Contribution and lifecycle instructions require a clean, pushed pull-request branch before handoff.
- [ ] Completion handoffs record delivery evidence.
- [ ] Public validation and offline Git-handoff validation pass without infrastructure access.

## Verification

- Scenario or command: run `make validate`, then validate the final pushed branch with the shared Agent Workspace Git handoff command and its pull-request URL.
- Expected observation: public checks pass locally and the handoff gate confirms a clean branch synchronized with its upstream.

## Blockers

- None

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Delivery:
- Follow-ups:
