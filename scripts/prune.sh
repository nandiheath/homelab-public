#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
public_repository=$(CDPATH='' cd -- "$script_dir/.." && pwd)
private_repository="$public_repository/../homelab-private"
kubeconfig="${HOME}/.kube/homelab-production"
kubectl="$public_repository/bin/kubectl"
timeout=20m
dry_run=false
reset=false

usage() {
  cat <<'USAGE'
Usage: scripts/prune.sh --reset [options]

Remove the manifests applied directly by scripts/bootstrap.sh, in reverse order.
GitOps-managed child workloads are orphaned rather than cascade-deleted.

Options:
  --reset                       Required teardown confirmation
  --dry-run                     Validate local inputs and print the reverse plan
  --kubeconfig PATH             Controller kubeconfig (default: ~/.kube/homelab-production)
  --kubectl PATH                kubectl executable (default: ./bin/kubectl)
  --private-repository PATH     Private homelab repository (default: ../homelab-private)
  --timeout DURATION            kubectl deletion timeout (default: 20m)
  -h, --help                    Show this help
USAGE
}

fail() {
  printf 'prune: %s\n' "$*" >&2
  exit 1
}

info() {
  printf 'prune: %s\n' "$*"
}

require_file() {
  [ -f "$1" ] || fail "required file is missing: $1"
}

require_dir() {
  [ -d "$1" ] || fail "required directory is missing: $1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --reset)
      reset=true
      shift
      ;;
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

"$reset" || fail 'refusing teardown without --reset'

public_project="$public_repository/artifacts/infrastructure/bootstrap/appproject_homelab-platform.yml"
public_root="$public_repository/artifacts/infrastructure/bootstrap/application_core-infrastructure-aoa.yml"
private_project="$private_repository/bootstrap/resources/appproject-homelab-private.yaml"
private_root="$private_repository/bootstrap/resources/application-private-aoa.yaml"

require_file "$public_project"
require_file "$public_root"
require_file "$private_project"
require_file "$private_root"
require_dir "$public_repository/artifacts/infrastructure/argocd"
require_dir "$public_repository/artifacts/infrastructure/istio-ztunnel"
require_dir "$public_repository/artifacts/infrastructure/istio-cni"
require_dir "$public_repository/artifacts/infrastructure/istiod"
require_dir "$public_repository/artifacts/infrastructure/istio-base"

print_plan() {
  cat <<EOF
Prune plan:
  1. Remove finalizers from Argo CD Applications to prevent cascade deletion.
  2. Delete private-aoa and its AppProject.
  3. Delete core-infrastructure-aoa and its AppProject.
  4. Delete Argo CD.
  5. Delete ztunnel, Istio CNI, istiod, and Istio base.
  6. Delete the Argo CD and Istio namespaces.

Public repository:  $public_repository
Private repository: $private_repository
Kubeconfig:         $kubeconfig
kubectl:            $kubectl
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

delete_file() {
  info "deleting $(basename -- "$1")"
  kube delete --ignore-not-found --wait --timeout="$timeout" -f "$1"
}

delete_directory() {
  info "deleting $1"
  kube delete --ignore-not-found --wait --timeout="$timeout" \
    -f "$public_repository/artifacts/infrastructure/$1/"
}

print_plan
info 'removing Argo CD Application finalizers without cascading child resources'
while IFS= read -r application; do
  [ -n "$application" ] || continue
  kube -n argocd patch "$application" --type=merge -p '{"metadata":{"finalizers":[]}}'
done < <(kube -n argocd get applications.argoproj.io -o name 2>/dev/null || true)

delete_file "$private_root"
delete_file "$private_project"
delete_file "$public_root"
delete_file "$public_project"
delete_directory argocd
delete_directory istio-ztunnel
delete_directory istio-cni
delete_directory istiod
delete_directory istio-base

info 'deleting bootstrap namespaces'
kube delete namespace argocd istio-system --ignore-not-found --wait --timeout="$timeout"

info 'bootstrap manifests removed in reverse order'
