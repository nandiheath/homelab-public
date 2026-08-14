#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
public_repository=$(CDPATH='' cd -- "$script_dir/.." && pwd)
private_repository="$public_repository/../homelab-private"
kubeconfig="${HOME}/.kube/homelab-production"
kubectl="$public_repository/bin/kubectl"
timeout=20m
dry_run=false
force_conflicts=false

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [options]

Bootstrap Istio before Argo CD, seed the public and private app-of-apps roots,
then return control to Argo CD.

Options:
  --dry-run                     Validate local inputs and print the ordered plan
  --force-conflicts             Pass --force-conflicts to server-side apply
  --kubeconfig PATH             Controller kubeconfig (default: ~/.kube/homelab-production)
  --kubectl PATH                kubectl executable (default: ./bin/kubectl)
  --private-repository PATH     Private homelab repository (default: ../homelab-private)
  --timeout DURATION            kubectl wait timeout (default: 20m)
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
    --force-conflicts)
      force_conflicts=true
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

    --timeout)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      timeout=$2
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

public_project="$public_repository/artifacts/infrastructure/bootstrap/appproject_homelab-platform.yml"
public_root="$public_repository/artifacts/infrastructure/bootstrap/application_core-infrastructure-aoa.yml"
private_project="$private_repository/bootstrap/resources/appproject-homelab-private.yaml"
private_root="$private_repository/bootstrap/resources/application-private-aoa.yaml"

require_dir "$public_repository/artifacts/infrastructure/istio-base"
require_dir "$public_repository/artifacts/infrastructure/istiod"
require_dir "$public_repository/artifacts/infrastructure/istio-cni"
require_dir "$public_repository/artifacts/infrastructure/istio-ztunnel"
require_dir "$public_repository/artifacts/infrastructure/argocd"
require_file "$public_project"
require_file "$public_root"
require_file "$private_project"
require_file "$private_root"

print_plan() {
  cat <<EOF
Bootstrap plan:
  1. Validate the protected kubeconfig, API, nodes, Cilium, and CoreDNS.
  2. Create the Istio and Argo CD namespaces outside ambient mode.
  3. Apply and verify Istio base, istiod, Istio CNI, and ztunnel.
  4. Apply and restart Argo CD after the healthy Istio data plane exists.
  5. Seed Application/core-infrastructure-aoa.
  6. Seed Application/private-aoa.
  7. Remove the obsolete root Application identities without cascading.

Public repository:  $public_repository
Private repository: $private_repository
Kubeconfig:         $kubeconfig
kubectl:            $kubectl
Force conflicts:    $force_conflicts
EOF
}

if "$dry_run"; then
  print_plan
  exit 0
fi


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

apply_options=(apply --server-side)
if "$force_conflicts"; then
  apply_options+=(--force-conflicts)
fi

apply_directory() {
  info "applying $1"
  kube "${apply_options[@]}" -f "$public_repository/artifacts/infrastructure/$1/"
}

apply_file() {
  info "applying $(basename -- "$1")"
  kube "${apply_options[@]}" -f "$1"
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
  cat <<EOF | kube "${apply_options[@]}" -f -
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

remove_obsolete_application() {
  local name=$1
  if resource_exists argocd "application/$name"; then
    info "removing obsolete Application/$name without cascading"
    kube -n argocd patch "application/$name" --type=merge -p '{"metadata":{"finalizers":[]}}'
    kube -n argocd delete "application/$name" --ignore-not-found
  fi
}

print_plan
info "validating controller context and cluster health"
kube config current-context
kube get --raw=/readyz >/dev/null
kube wait --for=condition=Ready nodes --all --timeout="$timeout"
wait_rollout kube-system daemonset/cilium
wait_rollout kube-system daemonset/cilium-envoy
wait_rollout kube-system deployment/cilium-operator
wait_rollout kube-system deployment/coredns

ensure_namespace istio-system istio
ensure_namespace argocd argocd
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

apply_file "$public_project"
apply_file "$public_root"
apply_file "$private_project"
apply_file "$private_root"
kube -n argocd wait --for=create application/core-infrastructure-aoa --timeout="$timeout"
kube -n argocd wait --for=create application/private-aoa --timeout="$timeout"

remove_obsolete_application infrastructure-app-of-apps
remove_obsolete_application homelab-private
remove_obsolete_application homelab-bootstrap

info "bootstrap completed: Istio and Argo CD are ready; core-infrastructure-aoa and private-aoa are seeded for GitOps reconciliation"
