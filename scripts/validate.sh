#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
export PATH="$REPO_ROOT/bin:$PATH"
cd "$REPO_ROOT"

required_tools=(actionlint helm homelab kubeconform kustomize shellcheck yq)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Error: required tool %s is unavailable. Run source bin/activate-hermit.\n' "$tool" >&2
    exit 1
  fi
done

if [[ "$(homelab version)" != "0.5.0" ]]; then
  printf 'Error: homelab 0.5.0 is required by the shared render and lifecycle contract.\n' >&2
  exit 1
fi

expected_istio_version=1.30.3
istio_sources=(
  argocd/infrastructure/istio-base/kustomization.yaml
  argocd/infrastructure/istio-cni/kustomization.yaml
  argocd/infrastructure/istiod/kustomization.yaml
  argocd/infrastructure/istio-ztunnel/kustomization.yaml
  argocd/infrastructure/istio-ingressgateway/kustomization.yaml
)
for source in "${istio_sources[@]}"; do
  if [[ "$(yq -r '.helmCharts[].version' "$source")" != "$expected_istio_version" ]]; then
    printf 'Error: %s must use Istio %s.\n' "$source" "$expected_istio_version" >&2
    exit 1
  fi
done

istio_artifacts=(
  artifacts/infrastructure/istio-base/customresourcedefinition_authorizationpolicies-security-istio-io.yml
  artifacts/infrastructure/istio-cni/daemonset_istio-cni-node.yml
  artifacts/infrastructure/istiod/deployment_istiod.yml
  artifacts/infrastructure/istio-ztunnel/daemonset_ztunnel.yml
  artifacts/infrastructure/istio-ingressgateway/deployment_istio-ingressgateway.yml
)
for artifact in "${istio_artifacts[@]}"; do
  if [[ "$(yq -r '.metadata.labels."app.kubernetes.io/version"' "$artifact")" != "$expected_istio_version" ]]; then
    printf 'Error: %s must render Istio %s.\n' "$artifact" "$expected_istio_version" >&2
    exit 1
  fi
done

if [[ "$(yq -o=json -I=0 '
  .helmCharts[]
  | select(.name == "istiod")
  | .valuesInline.meshConfig.defaultConfig.proxyMetadata.ISTIO_META_ENABLE_HBONE
' argocd/infrastructure/istiod/kustomization.yaml)" != '"true"' ]]; then
  printf 'Error: istiod mesh defaults must enable HBONE with string proxy metadata.\n' >&2
  exit 1
fi
if [[ "$(yq -o=json -I=0 '
  .data.mesh
  | from_yaml
  | .defaultConfig.proxyMetadata.ISTIO_META_ENABLE_HBONE
' artifacts/infrastructure/istiod/configmap_istio.yml)" != '"true"' ]]; then
  printf 'Error: rendered Istio mesh config must enable HBONE with string proxy metadata.\n' >&2
  exit 1
fi
if [[ "$(yq -o=json -I=0 '
  .spec.template.spec.containers[]
  | select(.name == "istio-proxy")
  | .env[]
  | select(.name == "ISTIO_META_ENABLE_HBONE")
  | .value
' artifacts/infrastructure/istio-ingressgateway/deployment_istio-ingressgateway.yml)" != '"true"' ]]; then
  printf 'Error: rendered ingress gateway must advertise HBONE capability.\n' >&2
  exit 1
fi
if [[ "$(yq -o=json -I=0 '
  [.spec.ports[] | [.name, .port, .targetPort, .protocol]]
' artifacts/infrastructure/istio-ingressgateway/service_istio-ingressgateway.yml)" != \
  '[["status-port",15021,15021,"TCP"],["http2",80,80,"TCP"],["https",443,443,"TCP"],["tls-mqtt",8883,8883,"TCP"]]' ]]; then
  printf 'Error: rendered ingress gateway Service contract changed.\n' >&2
  exit 1
fi

actionlint
shellcheck -x scripts/*.sh tests/bootstrap/*.sh
kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  artifacts/
