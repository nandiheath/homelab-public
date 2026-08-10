#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
public_repository=$(CDPATH='' cd -- "$script_dir/.." && pwd)
private_repository="$public_repository/../homelab-private"
kubeconfig="${HOME}/.kube/homelab-production"
kubectl="$public_repository/bin/kubectl"
timeout=20m
cluster_id=
authorization=
dry_run=false

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [options]

Bootstrap Istio before Argo CD, then hand the cluster to public/private GitOps.

Options:
  --dry-run                     Validate local inputs and print the ordered plan
  --kubeconfig PATH             Controller kubeconfig (default: ~/.kube/homelab-production)
  --kubectl PATH                kubectl executable (default: ./bin/kubectl)
  --private-repository PATH     Private homelab repository (default: ../homelab-private)
  --cluster-id ID               Authorization identity (default: kubeconfig basename)
  --timeout DURATION            kubectl wait timeout (default: 20m)
  --authorize TEXT              Exact BOOTSTRAP <cluster-id> confirmation
  -h, --help                    Show this help
USAGE
}

fail() {
  printf 'bootstrap: %s\n' "$*" >&2
  exit 1
}

info() {
  printf 'bootstrap: %s\n' "$*"
}

require_file() {
  [ -f "$1" ] || fail "required file is missing: $1"
}

require_dir() {
  [ -d "$1" ] || fail "required directory is missing: $1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    --kubeconfig)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      kubeconfig=$2
      shift 2
      ;;
    --kubectl)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      kubectl=$2
      shift 2
      ;;
    --private-repository)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      private_repository=$2
      shift 2
      ;;
    --cluster-id)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      cluster_id=$2
      shift 2
      ;;
    --timeout)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      timeout=$2
      shift 2
      ;;
    --authorize)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      authorization=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

[ -n "$cluster_id" ] || cluster_id=$(basename -- "$kubeconfig")
required_authorization="BOOTSTRAP $cluster_id"

require_dir "$public_repository/artifacts/infrastructure/istio-base"
require_dir "$public_repository/artifacts/infrastructure/istiod"
require_dir "$public_repository/artifacts/infrastructure/istio-cni"
require_dir "$public_repository/artifacts/infrastructure/istio-ztunnel"
require_dir "$public_repository/artifacts/infrastructure/argocd"
require_dir "$public_repository/artifacts/infrastructure/cert-manager"
require_dir "$public_repository/artifacts/infrastructure/external-secrets"
require_dir "$public_repository/artifacts/infrastructure/1password-connect"
require_dir "$public_repository/artifacts/infrastructure/bootstrap"
require_file "$private_repository/bootstrap/resources/appproject-homelab-private.yaml"
require_file "$private_repository/bootstrap/resources/application-cilium.yaml"
require_file "$private_repository/bootstrap/resources/application-homelab-private.yaml"
require_file "$private_repository/bootstrap/application-homelab-bootstrap.yaml"

print_plan() {
  cat <<EOF
Bootstrap plan:
  1. Validate the protected kubeconfig, API, nodes, Cilium, and CoreDNS.
  2. Create bootstrap namespaces without ambient enrollment.
  3. Remove ambient enrollment from the Argo CD and Istio control planes.
  4. Apply and verify Istio base, istiod, Istio CNI, and ztunnel.
  5. Apply and restart Argo CD after the healthy Istio data plane exists.
  6. Apply cert-manager, External Secrets, and 1Password Connect in dependency order.
  7. Apply the public root and private GitOps ownership resources.
  8. Verify every expected Application, final Cilium/Hubble TLS, and control-plane isolation.

Public repository:  $public_repository
Private repository: $private_repository
Kubeconfig:         $kubeconfig
kubectl:            $kubectl
Required live authorization: $required_authorization
EOF
}

if "$dry_run"; then
  print_plan
  exit 0
fi

[ "$authorization" = "$required_authorization" ] ||
  fail "authorization must be exactly: $required_authorization"
require_file "$kubeconfig"

if [[ "$kubectl" == */* ]]; then
  [ -x "$kubectl" ] || fail "kubectl is not executable: $kubectl"
elif ! command -v "$kubectl" >/dev/null 2>&1; then
  fail "kubectl is unavailable: $kubectl"
fi

file_mode() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

[ "$(file_mode "$kubeconfig")" = 600 ] ||
  fail "kubeconfig must have mode 0600: $kubeconfig"

kube() {
  "$kubectl" --kubeconfig="$kubeconfig" "$@"
}

apply_directory() {
  info "applying $1"
  kube apply --server-side -f "$public_repository/artifacts/infrastructure/$1/"
}

apply_file() {
  info "applying $(basename -- "$1")"
  kube apply --server-side -f "$1"
}

resource_exists() {
  local namespace=$1
  local resource=$2
  kube -n "$namespace" get "$resource" >/dev/null 2>&1
}

ensure_namespace() {
  local name=$1
  local part_of=$2
  info "ensuring namespace/$name without ambient enrollment"
  cat <<EOF | kube apply --server-side -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $name
  labels:
    app.kubernetes.io/part-of: $part_of
EOF
}

remove_ambient_label() {
  local name=$1
  local value
  value=$(kube get namespace "$name" -o jsonpath='{.metadata.labels.istio\.io/dataplane-mode}' 2>/dev/null || true)
  if [ -n "$value" ]; then
    info "removing ambient enrollment from namespace/$name"
    kube label namespace "$name" istio.io/dataplane-mode-
  fi
}

wait_rollout() {
  local namespace=$1
  local resource=$2
  info "waiting for $namespace/$resource"
  kube -n "$namespace" rollout status "$resource" --timeout="$timeout"
}

wait_application() {
  local name=$1
  info "waiting for Application/$name to become Synced and Healthy"
  kube -n argocd wait --for=create "application/$name" --timeout="$timeout"
  kube -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced "application/$name" --timeout="$timeout"
  kube -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy "application/$name" --timeout="$timeout"
}

assert_not_ambient() {
  local name=$1
  local value
  value=$(kube get namespace "$name" -o jsonpath='{.metadata.labels.istio\.io/dataplane-mode}')
  [ "$value" != ambient ] || fail "namespace/$name was re-enrolled in ambient mode; publish the reviewed namespace source before bootstrap"
}

create_connect_secrets() {
  local credential_directory="$public_repository/credentials/1password"
  local token_file="$credential_directory/1password-token.txt"
  local credentials_file="$credential_directory/1password-credentials.json"
  local token_b64
  local credentials_b64

  if ! resource_exists external-secrets secret/onepassword-connect-token; then
    require_file "$token_file"
    token_b64=$(tr -d '\r\n' <"$token_file" | base64 | tr -d '\n')
    info "creating Secret/external-secrets/onepassword-connect-token"
    cat <<EOF | kube apply --server-side -f -
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-connect-token
  namespace: external-secrets
type: Opaque
data:
  token: $token_b64
EOF
    unset token_b64
  fi

  if ! resource_exists 1password secret/op-credentials; then
    require_file "$credentials_file"
    credentials_b64=$(base64 <"$credentials_file" | tr -d '\n')
    info "creating Secret/1password/op-credentials"
    cat <<EOF | kube apply --server-side -f -
apiVersion: v1
kind: Secret
metadata:
  name: op-credentials
  namespace: 1password
type: Opaque
stringData:
  1password-credentials.json: $credentials_b64
EOF
    unset credentials_b64
  fi
}

print_plan
info "validating controller context and bare-cluster health"
kube config current-context
kube get --raw=/readyz >/dev/null
kube wait --for=condition=Ready nodes --all --timeout="$timeout"
wait_rollout kube-system daemonset/cilium
wait_rollout kube-system daemonset/cilium-envoy
wait_rollout kube-system deployment/cilium-operator
wait_rollout kube-system deployment/coredns

ensure_namespace istio-system istio
ensure_namespace argocd argocd
ensure_namespace cert-manager cert-manager
ensure_namespace external-secrets external-secrets
ensure_namespace 1password 1password
ensure_namespace cilium-secrets cilium
remove_ambient_label istio-system
remove_ambient_label argocd

apply_directory istio-base
kube wait --for=condition=Established \
  customresourcedefinition/authorizationpolicies.security.istio.io \
  customresourcedefinition/gateways.networking.istio.io \
  --timeout="$timeout"

apply_directory istiod
wait_rollout istio-system deployment/istiod
kube -n istio-system wait --for=jsonpath='{.subsets[0].addresses[0].ip}' endpoints/istiod --timeout="$timeout"
kube -n istio-system wait --for=create configmap/istio-ca-root-cert --timeout="$timeout"

apply_directory istio-cni
wait_rollout kube-system daemonset/istio-cni-node

apply_directory istio-ztunnel
wait_rollout istio-system daemonset/ztunnel

if resource_exists argocd job/argocd-redis-secret-init; then
  failed_job=$(kube -n argocd get job/argocd-redis-secret-init -o jsonpath='{.status.failed}')
  if [ -n "$failed_job" ] && [ "$failed_job" != 0 ]; then
    info "removing failed Argo CD Redis bootstrap Job"
    kube -n argocd delete job/argocd-redis-secret-init
  fi
fi

apply_directory argocd
kube -n argocd wait --for=condition=Complete job/argocd-redis-secret-init --timeout="$timeout"
info "restarting Argo CD outside ambient mode"
kube -n argocd rollout restart deployment
kube -n argocd rollout restart statefulset
for deployment in \
  argocd-applicationset-controller \
  argocd-dex-server \
  argocd-notifications-controller \
  argocd-redis \
  argocd-repo-server \
  argocd-server; do
  wait_rollout argocd "deployment/$deployment"
done
wait_rollout argocd statefulset/argocd-application-controller

apply_directory cert-manager
for deployment in cert-manager cert-manager-cainjector cert-manager-webhook; do
  wait_rollout cert-manager "deployment/$deployment"
done

apply_directory external-secrets
for deployment in external-secrets external-secrets-cert-controller external-secrets-webhook; do
  wait_rollout external-secrets "deployment/$deployment"
done

create_connect_secrets
probe_phase=$(kube -n 1password get pod/1password-health-check -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [ "$probe_phase" = Failed ]; then
  info "removing failed 1Password Connect health probe"
  kube -n 1password delete pod/1password-health-check
fi
apply_file "$public_repository/artifacts/infrastructure/1password-connect/deployment_onepassword-connect.yml"
apply_file "$public_repository/artifacts/infrastructure/1password-connect/service_onepassword-connect.yml"
wait_rollout 1password deployment/onepassword-connect
apply_file "$public_repository/artifacts/infrastructure/1password-connect/pod_1password-health-check.yml"
kube -n 1password wait --for=jsonpath='{.status.phase}'=Succeeded pod/1password-health-check --timeout="$timeout"

apply_file "$private_repository/bootstrap/resources/appproject-homelab-private.yaml"
apply_directory bootstrap
kube wait --for=condition=Ready clustersecretstore/onepassword --timeout="$timeout"
kube -n argocd wait --for=condition=Ready externalsecret/argocd-github-app --timeout="$timeout"
wait_application infrastructure-app-of-apps
wait_application cert-manager

apply_file "$private_repository/bootstrap/resources/application-cilium.yaml"
apply_file "$private_repository/bootstrap/resources/application-homelab-private.yaml"
apply_file "$private_repository/bootstrap/application-homelab-bootstrap.yaml"

for application in \
  1password-connect \
  argocd \
  cert-manager \
  cilium \
  cluster-namespaces \
  cnpg \
  external-secrets \
  grafana \
  homelab-bootstrap \
  homelab-private \
  infrastructure-app-of-apps \
  istio-base \
  istio-cni \
  istio-ingressgateway \
  istio-ztunnel \
  istiod \
  longhorn \
  metallb; do
  wait_application "$application"
done

wait_rollout kube-system daemonset/cilium
wait_rollout kube-system daemonset/cilium-envoy
wait_rollout kube-system deployment/cilium-operator
kube -n kube-system wait --for=jsonpath='{.data.hubble-disable-tls}'=false configmap/cilium-config --timeout="$timeout"
kube -n kube-system wait --for=condition=Ready certificate/hubble-server-certs --timeout="$timeout"
assert_not_ambient argocd
assert_not_ambient istio-system

info "bootstrap completed: Istio preceded Argo CD, GitOps is healthy, Hubble TLS is restored, and control planes are outside ambient mode"
