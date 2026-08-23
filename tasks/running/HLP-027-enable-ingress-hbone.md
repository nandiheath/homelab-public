# HLP-027 — Enable HBONE for injected Istio gateways

- Status: running
- Owner: Main
- Milestone: HLP-M010
- Depends on: none

## Owned paths

- `argocd/infrastructure/istiod/kustomization.yaml`
- `argocd/infrastructure/istio-ingressgateway/values.yaml`
- `artifacts/infrastructure/istiod/`
- `artifacts/infrastructure/istio-ingressgateway/`
- `scripts/validate.sh`
- `tasks/running/HLP-027-enable-ingress-hbone.md`
- `tasks/milestones/running/HLP-M010-ambient-ingress-transport.md`
- `PROJECT_STATUS.md`

## Goal

Enable injected Istio gateways to discover ambient workload endpoints as HBONE targets and originate Istio mutual TLS, without changing the ingress listener, LoadBalancer, Cloudflare Tunnel route, or application authorization policy.

## Implementation

1. Add the documented `ISTIO_META_ENABLE_HBONE` proxy metadata to Istio mesh defaults.
2. Set the same explicit metadata on the ingress gateway chart so its Deployment rolls and the running proxy advertises HBONE capability.
3. Extend repository validation to assert both source and rendered contracts.
4. Regenerate only the affected Istio artifacts through the repository renderer.
5. Under the existing current-session deployment authorization, reconcile and prove the gateway uses HBONE to the ambient Homelab Hub workload.

## Acceptance criteria

- [ ] Source and rendered mesh config set `defaultConfig.proxyMetadata.ISTIO_META_ENABLE_HBONE` to string `"true"`.
- [ ] Source and rendered ingress Deployment set `ISTIO_META_ENABLE_HBONE` to string `"true"` while its Service contract is unchanged.
- [ ] Focused renders, full repository validation, and task lifecycle validation pass.
- [ ] Live gateway discovery marks Homelab Hub endpoints for HBONE and an external request receives the Hub's unauthenticated API response instead of a TLS/reset transport failure.

## Verification

- Focused Istio renders and `./scripts/validate.sh`.
- `agent-workspace repo-tasks validate --root .`.
- Read-only live inspection of ingress proxy node metadata and Hub endpoint discovery, then an HTTPS request to the already authorized API hostname.

## Blockers

- None; the user explicitly authorized the Homelab Hub deployment and asked execution to continue until completion in the current conversation.

## Completion handoff

- Summary:
- Files changed:
- Observed verification:
- Follow-ups:
- Delivery:
