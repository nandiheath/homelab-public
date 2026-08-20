# HLP-M007 — Reusable MQTT ingress port

- Status: running
- Owner: Main

## Goal
Add the reusable Istio ingress-gateway Service port required for private opaque TLS MQTT while preserving the existing MetalLB VIP and HTTP/HTTPS behavior.

## Tasks

- [ ] HLP-025 — Add the TLS MQTT ingress-gateway Service port

## Acceptance criteria

- The public ingress LoadBalancer retains the existing selector, VIP contract, and ports 15021/80/443 while adding exactly one `8883`/`tls-mqtt` port.
- The generated artifact matches source and contains no private hostname, address, broker, credential, or route.
- No Gateway, VirtualService, NodePort, firewall, DNS, or cluster mutation is introduced in the reusable public repository.

## Verification

- Scenario or command: `source bin/activate-hermit && homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway && ./scripts/validate.sh`.
- Expected observation: render is deterministic, public validation passes, and source/artifact inspection finds one new port with all existing ports unchanged.

## Blockers

- The private Gateway and broker VirtualService consume this port only after the dependent private task is reviewed and separately authorized for GitOps reconciliation.

## Completion handoff

- Tasks rolled up:
- Observed milestone verification:
- Project status updated:
- Follow-ups:
