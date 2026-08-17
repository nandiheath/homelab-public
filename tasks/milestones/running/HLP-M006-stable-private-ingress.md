# HLP-M006 — Stable private cluster ingress

- Status: running
- Owner: Main

## Goal

Expose the existing Istio ingress gateway on one stable MetalLB address without changing its cluster-local Cloudflare Tunnel path.

## Tasks

- [ ] HLP-021 — Allocate stable Istio ingress address

## Acceptance criteria

- [ ] The Istio ingress gateway is a healthy `LoadBalancer` Service with the requested address from the selected MetalLB pool.
- [ ] Existing status, HTTP, and HTTPS ports and selector identity remain unchanged.
- [ ] The existing cluster-local Cloudflare Tunnel route remains functional.

## Verification

- Scenario or command: focused render, `make validate`, and live Service/endpoints/MetalLB inspection after authorized GitOps reconciliation.
- Expected observation: the rendered Service requests the reviewed pool/address; the live Service receives that address, has ready endpoints, and all MetalLB speakers remain Ready.

## Blockers

- Live reconciliation requires explicit current-session authorization.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Delivery:
- Follow-ups:
