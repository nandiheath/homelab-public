# HLP-025 — Add the TLS MQTT ingress-gateway Service port

- Status: running
- Owner: Main
- Milestone: HLP-M007
- Depends on: none

## Owned paths

- `tasks/running/HLP-025-mqtt-ingress-port.md`
- `tasks/milestones/running/HLP-M007-private-mqtt-ingress-port.md`
- `argocd/infrastructure/istio-ingressgateway/values.yaml`
- `artifacts/infrastructure/istio-ingressgateway/`

## Goal

Expose one reusable `8883`/`tls-mqtt` Service port on the existing Istio ingress gateway so a private repository can add an opaque TLS/SNI route without changing public routing or addresses.

## Implementation

1. Add only the new named Service port to the ingress-gateway values while preserving `15021`, `80`, `443`, selector identity, and the existing LoadBalancer configuration.
2. Regenerate the committed artifact with the Hermit-managed renderer; do not hand-edit generated output.
3. Keep all private hostname, VIP, broker, certificate, credential, and VirtualService policy in the private repository.

## Acceptance criteria

- Source and artifact each contain one `8883`/`tls-mqtt` port and retain the existing three ports exactly once.
- `homelab argocd render` and `./scripts/validate.sh` pass without contacting a cluster or registry.
- No address allocation, OpenWrt, Gateway, VirtualService, NodePort, or public-DNS file changes.

## Verification

- `source bin/activate-hermit && homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway`
- `./scripts/validate.sh`
- Inspect source and rendered Service for exact port preservation/addition.

## Blockers

- None for offline source/artifact work. Live use remains behind the private GitOps authorization gate.

## Completion handoff

- Summary: Added one reusable `tls-mqtt` Service port at 8883 and regenerated its committed artifact.
- Files changed: `argocd/infrastructure/istio-ingressgateway/values.yaml`, `artifacts/infrastructure/istio-ingressgateway/`, and this task contract.
- Observed verification: Hermit render succeeded; `./scripts/validate.sh` reported 351 resources with 246 valid, 0 invalid, and 0 errors; rendered Service preserved 15021/80/443 and added 8883 once.
- Follow-ups: Private Gateway/VirtualService remains gated behind HL-022 authorization.
