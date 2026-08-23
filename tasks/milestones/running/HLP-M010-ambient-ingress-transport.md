# HLP-M010 — Ambient ingress upstream transport

- Status: ready-for-rollup
- Owner: Main

## Goal

Make injected Istio gateways originate HBONE to ambient workloads so ingress-to-workload traffic retains Istio mutual TLS instead of attempting plaintext pod connections.

## Tasks

- [x] HLP-027 — Enable HBONE for injected Istio gateways

## Acceptance criteria

- [x] Istio proxy defaults advertise HBONE capability to injected proxies.
- [x] The ingress gateway rolls out with explicit HBONE node metadata and retains its reviewed Service contract.
- [x] Public rendering and validation pass with deterministic committed artifacts.
- [x] After separately authorized reconciliation, an ingress request reaches the ambient Homelab Hub workload and returns the application authentication response rather than an upstream transport reset.

## Verification

- Scenario or command: `source bin/activate-hermit && homelab argocd render --path argocd/infrastructure/istiod --output artifacts/infrastructure/istiod && homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway && ./scripts/validate.sh`.
- Expected observation: rendered Istio mesh config and gateway Deployment both carry `ISTIO_META_ENABLE_HBONE: "true"`; all repository checks pass; no gateway Service port, address-pool, or source-range setting changes.

## Blockers

- None; live reconciliation completed under the user's current-session authorization.

## Completion handoff

- Tasks rolled up: HLP-027, delivered through pull requests #50, #51, and #52.
- Observed milestone verification: Istio base, CNI, istiod, ztunnel, and ingress gateway are Healthy/Synced on 1.30.3. The live gateway advertises HBONE, discovers both Hub endpoints through `connect_originate` with `tunnel: http`, and three consecutive external requests returned the Hub's JSON 401 authentication response. `./scripts/validate.sh` reported 371 resources, 260 valid, 0 invalid, and 0 errors; task lifecycle validation and all six pull-request `Render and validate` checks passed.
- Project status updated: Yes; the supported Istio release and observed ambient ingress result are recorded without private topology.
- Follow-ups: None for ambient ingress transport.
