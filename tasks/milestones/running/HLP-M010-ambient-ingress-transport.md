# HLP-M010 — Ambient ingress upstream transport

- Status: running
- Owner: Main

## Goal

Make injected Istio gateways originate HBONE to ambient workloads so ingress-to-workload traffic retains Istio mutual TLS instead of attempting plaintext pod connections.

## Tasks

- [ ] HLP-027 — Enable HBONE for injected Istio gateways

## Acceptance criteria

- [ ] Istio proxy defaults advertise HBONE capability to injected proxies.
- [ ] The ingress gateway rolls out with explicit HBONE node metadata and retains its reviewed Service contract.
- [ ] Public rendering and validation pass with deterministic committed artifacts.
- [ ] After separately authorized reconciliation, an ingress request reaches the ambient Homelab Hub workload and returns the application authentication response rather than an upstream transport reset.

## Verification

- Scenario or command: `source bin/activate-hermit && homelab argocd render --path argocd/infrastructure/istiod --output artifacts/infrastructure/istiod && homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway && ./scripts/validate.sh`.
- Expected observation: rendered Istio mesh config and gateway Deployment both carry `ISTIO_META_ENABLE_HBONE: "true"`; all repository checks pass; no gateway Service port, address-pool, or source-range setting changes.

## Blockers

- Live reconciliation requires explicit current-session authorization.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
