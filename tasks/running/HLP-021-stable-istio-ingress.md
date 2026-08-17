# HLP-021 — Allocate stable Istio ingress address

- Status: running
- Owner: Main
- Milestone: HLP-M006
- Depends on: none

## Owned paths

- `argocd/infrastructure/istio-ingressgateway/values.yaml`
- `artifacts/infrastructure/istio-ingressgateway/`
- `tasks/running/HLP-021-stable-istio-ingress.md`

## Goal

Expose the existing Istio ingress gateway at one stable MetalLB address for private clients while preserving the existing cluster-local ingress path.

## Implementation

1. Change the gateway Service to `LoadBalancer`, request the reviewed address, and bind it to the `homelab-lb` MetalLB pool.
2. Preserve ports `15021`, `80`, and `443`, selector identity, and existing service routing.
3. Render the source and verify the live Service, endpoints, allocation, and MetalLB speakers after authorized GitOps reconciliation.

## Acceptance criteria

- [ ] The rendered Service is `LoadBalancer`, requests the reviewed stable address and MetalLB pool, and preserves all existing ports and selectors.
- [ ] The live Service receives the requested address and has Ready endpoints.
- [ ] MetalLB advertises the allocation while every expected speaker Pod remains Ready.
- [ ] The existing cluster-local Cloudflare Tunnel route remains healthy.

## Verification

- `homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway` — focused source and artifact agree.
- `make validate` — public desired state and task lifecycle pass.
- Authorized live Service, EndpointSlice, speaker, and Cloudflare Tunnel inspections — stable private ingress is operational without changing the tunnel path.

## Blockers

- None.

## Completion handoff

- Summary: Changed the existing Istio ingress gateway Service from `ClusterIP` to `LoadBalancer`, requested `10.43.10.100`, and selected MetalLB pool `homelab-lb` without changing its selector or ports.
- Files changed: `argocd/infrastructure/istio-ingressgateway/values.yaml`; `artifacts/infrastructure/istio-ingressgateway/service_istio-ingressgateway.yml`; this task contract; parent milestone contract.
- Observed verification: Focused `homelab argocd render` completed successfully. `make validate` passed: Ansible/lifecycle/bootstrap fixtures passed and manifest validation reported 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped. The rendered Service preserves ports `15021`, `80`, and `443`, preserves selectors `app: istio-ingressgateway` and `istio: ingressgateway`, requests `10.43.10.100`, and selects pool `homelab-lb`. Live proof remains pending publication and Argo reconciliation.
- Delivery:
- Follow-ups: Record the allocated address, Ready endpoints, active L2 announcer, speaker readiness, and existing Cloudflare Tunnel health after publication.
