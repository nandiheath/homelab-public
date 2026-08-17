# HLP-021 — Allocate stable Istio ingress address

- Status: ready-for-rollup
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

- [x] The rendered Service is `LoadBalancer`, requests the reviewed stable address and MetalLB pool, and preserves all existing ports and selectors.
- [x] The live Service receives the requested address and has Ready endpoints.
- [x] MetalLB advertises the allocation while every expected speaker Pod remains Ready.
- [x] The existing cluster-local Cloudflare Tunnel route remains healthy.

## Verification

- `homelab argocd render --path argocd/infrastructure/istio-ingressgateway --output artifacts/infrastructure/istio-ingressgateway` — focused source and artifact agree.
- `make validate` — public desired state and task lifecycle pass.
- Authorized live Service, EndpointSlice, speaker, and Cloudflare Tunnel inspections — stable private ingress is operational without changing the tunnel path.

## Blockers

- None.

## Completion handoff

- Summary: Changed the existing Istio ingress gateway Service from `ClusterIP` to `LoadBalancer`, requested `10.43.10.100`, and selected MetalLB pool `homelab-lb` without changing its selector or ports.
- Files changed: `argocd/infrastructure/istio-ingressgateway/values.yaml`; `artifacts/infrastructure/istio-ingressgateway/service_istio-ingressgateway.yml`; this task contract; parent milestone contract.
- Observed verification: Focused `homelab argocd render` completed successfully. `make validate` passed: Ansible/lifecycle/bootstrap fixtures passed and manifest validation reported 351 resources, 246 valid, 0 invalid, 0 errors, and 105 schema-skipped. The live `istio-ingressgateway` Service is `LoadBalancer`, requests and receives `10.43.10.100` from `homelab-lb`, preserves ports `15021`, `80`, and `443`, and has a Ready EndpointSlice endpoint. `ServiceL2Status/l2-p79vp` identifies `node-rpi-0` as the active announcer; all three speaker DaemonSet Pods have four ready containers and are Running. Argo reports `cloudflared` Synced/Healthy, its Deployment is 2/2 Available, both tunnel Pods are Running, its config still routes to `http://istio-ingressgateway.istio-system.svc.cluster.local`, and its connection prechecks pass. A port-forwarded Host-header request through the gateway returned an upstream application 404 with `x-envoy-upstream-service-time`, proving the unchanged cluster-local route reached the Peripheral Hub rather than the gateway's no-route response.
- Delivery: Source merged in pull request #30 (`2d64813`); live proof observed on 2026-08-17.
- Follow-ups: The private repository can now add internal TLS/SNI host routing and Archer DNS against the stable address.
