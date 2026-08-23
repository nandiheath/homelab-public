# HLP-027 — Enable HBONE for injected Istio gateways

- Status: ready-for-rollup
- Owner: Main
- Milestone: HLP-M010
- Depends on: none

## Owned paths

- `argocd/infrastructure/istio-base/kustomization.yaml`
- `argocd/infrastructure/istio-cni/kustomization.yaml`
- `argocd/infrastructure/istiod/kustomization.yaml`
- `argocd/infrastructure/istio-ztunnel/kustomization.yaml`
- `argocd/infrastructure/istio-ingressgateway/kustomization.yaml`
- `argocd/infrastructure/istio-ingressgateway/values.yaml`
- `artifacts/infrastructure/istio-base/`
- `artifacts/infrastructure/istio-cni/`
- `artifacts/infrastructure/istiod/`
- `artifacts/infrastructure/istio-ztunnel/`
- `artifacts/infrastructure/istio-ingressgateway/`
- `scripts/validate.sh`
- `tasks/running/HLP-027-enable-ingress-hbone.md`
- `tasks/milestones/running/HLP-M010-ambient-ingress-transport.md`
- `PROJECT_STATUS.md`

## Goal

Enable injected Istio gateways to discover ambient workload endpoints as HBONE targets and originate Istio mutual TLS, without changing the ingress listener, LoadBalancer, Cloudflare Tunnel route, or application authorization policy.

## Implementation

1. Upgrade every Istio base, CNI, control-plane, ztunnel, and gateway chart together from unsupported 1.24.5 to supported 1.30.3; Istio fixed the observed sidecar/gateway-to-ambient `WRONG_VERSION_NUMBER` HBONE failure in 1.25.
2. Add the documented `ISTIO_META_ENABLE_HBONE` proxy metadata to Istio mesh defaults.
3. Set the same explicit metadata on the ingress gateway chart so its Deployment rolls and the running proxy advertises HBONE capability.
4. Extend repository validation to assert the coherent Istio version and both source and rendered HBONE contracts.
5. Regenerate only the affected Istio artifacts through the repository renderer.
6. Under the existing current-session deployment authorization, reconcile and prove the gateway uses HBONE to the ambient Homelab Hub workload.

## Acceptance criteria

- [x] Source and rendered Istio base, CNI, control-plane, ztunnel, and gateway resources use the same supported 1.30.3 release.
- [x] Source and rendered mesh config set `defaultConfig.proxyMetadata.ISTIO_META_ENABLE_HBONE` to string `"true"`.
- [x] Source and rendered ingress Deployment set `ISTIO_META_ENABLE_HBONE` to string `"true"` while its Service contract is unchanged.
- [x] Focused renders, full repository validation, and task lifecycle validation pass.
- [x] Live gateway discovery marks Homelab Hub endpoints for HBONE and an external request receives the Hub's unauthenticated API response instead of a TLS/reset transport failure.

## Verification

- Focused Istio renders and `./scripts/validate.sh`.
- `agent-workspace repo-tasks validate --root .`.
- Read-only live inspection of ingress proxy node metadata and Hub endpoint discovery, then an HTTPS request to the already authorized API hostname.

## Blockers

- None; the user explicitly authorized the Homelab Hub deployment and asked execution to continue until completion in the current conversation.

## Completion handoff

- Summary: Upgraded the complete Istio ambient stack from unsupported 1.24.5 to 1.30.3, enabled HBONE metadata for mesh defaults and the injected ingress gateway, and restored ingress-to-Hub application delivery over ambient mTLS.
- Files changed: Istio base/CNI/istiod/ztunnel/gateway chart pins and rendered artifacts; istiod and ingress HBONE values; validation assertions.
- Observed verification: PRs #50 and #51 merged after two passing `Render and validate` checks each. Local `./scripts/validate.sh` found 371 resources with 260 valid, 0 invalid, and 0 errors; `/Users/nandi/workspace/agent-workspace/bin/agent-workspace repo-tasks validate --root .` passed. All five Istio Argo CD applications are Healthy/Synced at `bfbe82e440bc58f4fb98fe9832f2491ee3aaf541`; CNI, istiod, ztunnel, and ingress run 1.30.3. Live EDS marks both Hub endpoints with `tunnel: http`, and three consecutive external `/v1/me` requests returned the Hub's `401 {"error":"authentication required"}` instead of 503/reset.
- Follow-ups: None for transport; exact household enrollment and authenticated DPoP flows remain in the parent Homelab Hub activation milestone.
- Delivery: https://github.com/nandiheath/homelab-public/pull/50 and https://github.com/nandiheath/homelab-public/pull/51
