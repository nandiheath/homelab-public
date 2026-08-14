#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
bootstrap_script="$repo_root/scripts/bootstrap.sh"
prune_script="$repo_root/scripts/prune.sh"
fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-fixture.XXXXXX")
trap 'rm -rf "$fixture_dir"' EXIT
fixture_log="$fixture_dir/kubectl.log"
fixture_state="$fixture_dir/state"
private_repository="$fixture_dir/homelab-private"
mkdir -p "$fixture_state" "$private_repository/bootstrap/resources"
touch \
  "$private_repository/bootstrap/resources/application-private-aoa.yaml" \
  "$private_repository/bootstrap/resources/appproject-homelab-private.yaml"

fail() {
  printf 'bootstrap fixture: %s\n' "$*" >&2
  exit 1
}

line_of() {
  local file=$1
  local literal=$2
  local line
  line=$(grep -nF -- "$literal" "$file" | cut -d: -f1 | sed -n '1p')
  [ -n "$line" ] || fail "missing log entry: $literal"
  printf '%s\n' "$line"
}

plan=$($bootstrap_script --dry-run --force-conflicts --private-repository "$private_repository")
printf '%s\n' "$plan" | grep -Fq 'Apply and verify Istio base, istiod, Istio CNI, and ztunnel.' ||
  fail 'dry-run omits the staged Istio data plane'
printf '%s\n' "$plan" | grep -Fq 'Seed Application/core-infrastructure-aoa.' ||
  fail 'dry-run omits the public app-of-apps root'
printf '%s\n' "$plan" | grep -Fq 'Seed Application/private-aoa.' ||
  fail 'dry-run omits the private app-of-apps root'
printf '%s\n' "$plan" | grep -Fq 'Force conflicts:    true' ||
  fail 'dry-run does not report forced conflict ownership'
istio_plan_line=$(printf '%s\n' "$plan" | grep -nF 'Apply and verify Istio base' | cut -d: -f1)
argocd_plan_line=$(printf '%s\n' "$plan" | grep -nF 'Apply and restart Argo CD' | cut -d: -f1)
[ "$istio_plan_line" -lt "$argocd_plan_line" ] || fail 'dry-run places Argo CD before Istio'

for namespace in argocd istio-system; do
  "$repo_root/bin/yq" -e '.metadata.labels."istio.io/dataplane-mode" == null' \
    "$repo_root/argocd/infrastructure/cluster-namespaces/namespace-${namespace}.yaml" >/dev/null ||
    fail "namespace/$namespace remains ambient-enrolled"
  "$repo_root/bin/yq" -e '.metadata.labels."istio.io/dataplane-mode" == null' \
    "$repo_root/artifacts/infrastructure/cluster-namespaces/namespace_${namespace}.yml" >/dev/null ||
    fail "rendered namespace/$namespace remains ambient-enrolled"
done

if "$bootstrap_script" --private-repository "$private_repository" --authorize obsolete >"$fixture_dir/obsolete-auth.out" 2>&1; then
  fail 'removed --authorize option unexpectedly succeeded'
fi
grep -Fq 'unknown option: --authorize' "$fixture_dir/obsolete-auth.out" ||
  fail 'removed --authorize option was not rejected'

printf 'fixture\n' >"$fixture_dir/kubeconfig"
chmod 0600 "$fixture_dir/kubeconfig"

cat >"$fixture_dir/kubectl" <<'FAKE'
#!/usr/bin/env bash
set -Eeuo pipefail
printf '%s\n' "$*" >>"$BOOTSTRAP_FIXTURE_LOG"
joined=" $* "
case "$joined" in
  *' config current-context '*)
    printf 'fixture-context\n'
    ;;
  *' get namespace argocd -o jsonpath='*)
    [ -f "$BOOTSTRAP_FIXTURE_STATE/argocd-clear" ] || printf 'ambient'
    ;;
  *' get namespace istio-system -o jsonpath='*)
    [ -f "$BOOTSTRAP_FIXTURE_STATE/istio-system-clear" ] || printf 'ambient'
    ;;
  *' label namespace argocd istio.io/dataplane-mode- '*)
    touch "$BOOTSTRAP_FIXTURE_STATE/argocd-clear"
    ;;
  *' label namespace istio-system istio.io/dataplane-mode- '*)
    touch "$BOOTSTRAP_FIXTURE_STATE/istio-system-clear"
    ;;
  *' get applications.argoproj.io -o name '*)
    printf 'application.argoproj.io/core-infrastructure-aoa\n'
    printf 'application.argoproj.io/private-aoa\n'
    ;;
esac
FAKE
chmod 0700 "$fixture_dir/kubectl"

BOOTSTRAP_FIXTURE_LOG=$fixture_log \
BOOTSTRAP_FIXTURE_STATE=$fixture_state \
  "$bootstrap_script" \
  --force-conflicts \
  --kubectl "$fixture_dir/kubectl" \
  --kubeconfig "$fixture_dir/kubeconfig" \
  --private-repository "$private_repository" >"$fixture_dir/bootstrap-output"

istiod_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istiod/')
ztunnel_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istio-ztunnel/')
argocd_line=$(line_of "$fixture_log" '/artifacts/infrastructure/argocd/')
public_root_line=$(line_of "$fixture_log" 'application_core-infrastructure-aoa.yml')
private_root_line=$(line_of "$fixture_log" 'application-private-aoa.yaml')
old_public_line=$(line_of "$fixture_log" 'patch application/infrastructure-app-of-apps')
old_private_line=$(line_of "$fixture_log" 'patch application/homelab-private')
old_ownership_line=$(line_of "$fixture_log" 'patch application/homelab-bootstrap')
[ "$istiod_line" -lt "$ztunnel_line" ] || fail 'ztunnel was applied before istiod'
[ "$ztunnel_line" -lt "$argocd_line" ] || fail 'Argo CD was applied before ztunnel'
[ "$argocd_line" -lt "$public_root_line" ] || fail 'the public root was applied before Argo CD'
[ "$public_root_line" -lt "$private_root_line" ] || fail 'the private root was applied before the public root'
[ "$private_root_line" -lt "$old_public_line" ] || fail 'the old public root was removed before replacement'
[ "$private_root_line" -lt "$old_private_line" ] || fail 'the old private root was removed before replacement'
[ "$private_root_line" -lt "$old_ownership_line" ] || fail 'the old ownership root was removed before replacement'

if grep -F ' apply --server-side ' "$fixture_log" | grep -Fvq -- '--force-conflicts'; then
  fail 'an apply command omitted the requested --force-conflicts flag'
fi
for forbidden in \
  '/artifacts/infrastructure/cert-manager/' \
  '/artifacts/infrastructure/external-secrets/' \
  '/artifacts/infrastructure/1password-connect/' \
  'application-cilium.yaml' \
  'application-homelab-bootstrap.yaml'; do
  if grep -Fq -- "$forbidden" "$fixture_log"; then
    fail "bootstrap continued past app-of-apps seeding: $forbidden"
  fi
done

grep -Fq 'label namespace argocd istio.io/dataplane-mode-' "$fixture_log" ||
  fail 'Argo CD recovery did not remove ambient enrollment'
grep -Fq 'label namespace istio-system istio.io/dataplane-mode-' "$fixture_log" ||
  fail 'Istio recovery did not remove ambient enrollment'
grep -Fq 'core-infrastructure-aoa and private-aoa are seeded' "$fixture_dir/bootstrap-output" ||
  fail 'bootstrap omitted the app-of-apps handoff boundary'

if BOOTSTRAP_FIXTURE_LOG=$fixture_log BOOTSTRAP_FIXTURE_STATE=$fixture_state \
  "$prune_script" \
  --kubectl "$fixture_dir/kubectl" \
  --kubeconfig "$fixture_dir/kubeconfig" \
  --private-repository "$private_repository" >"$fixture_dir/missing-reset.out" 2>&1; then
  fail 'prune unexpectedly ran without --reset'
fi
grep -Fq 'refusing teardown without --reset' "$fixture_dir/missing-reset.out" ||
  fail 'prune did not fail closed without --reset'

prune_plan=$($prune_script --reset --dry-run --private-repository "$private_repository")
printf '%s\n' "$prune_plan" | grep -Fq 'Delete private-aoa and its AppProject.' ||
  fail 'prune dry-run omits the private root'
printf '%s\n' "$prune_plan" | grep -Fq 'Delete ztunnel, Istio CNI, istiod, and Istio base.' ||
  fail 'prune dry-run omits reverse Istio teardown'

: >"$fixture_log"
BOOTSTRAP_FIXTURE_LOG=$fixture_log \
BOOTSTRAP_FIXTURE_STATE=$fixture_state \
  "$prune_script" \
  --reset \
  --kubectl "$fixture_dir/kubectl" \
  --kubeconfig "$fixture_dir/kubeconfig" \
  --private-repository "$private_repository" >"$fixture_dir/prune-output"

finalizer_line=$(line_of "$fixture_log" 'patch application.argoproj.io/core-infrastructure-aoa')
prune_private_line=$(line_of "$fixture_log" 'application-private-aoa.yaml')
prune_public_line=$(line_of "$fixture_log" 'application_core-infrastructure-aoa.yml')
prune_argocd_line=$(line_of "$fixture_log" '/artifacts/infrastructure/argocd/')
prune_ztunnel_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istio-ztunnel/')
prune_cni_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istio-cni/')
prune_istiod_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istiod/')
prune_base_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istio-base/')
prune_namespace_line=$(line_of "$fixture_log" 'delete namespace argocd istio-system')
[ "$finalizer_line" -lt "$prune_private_line" ] || fail 'Application finalizers were not removed before pruning'
[ "$prune_private_line" -lt "$prune_public_line" ] || fail 'private root was not pruned before public root'
[ "$prune_public_line" -lt "$prune_argocd_line" ] || fail 'Argo CD was pruned before app-of-apps roots'
[ "$prune_argocd_line" -lt "$prune_ztunnel_line" ] || fail 'ztunnel was pruned before Argo CD'
[ "$prune_ztunnel_line" -lt "$prune_cni_line" ] || fail 'Istio CNI was pruned before ztunnel'
[ "$prune_cni_line" -lt "$prune_istiod_line" ] || fail 'istiod was pruned before Istio CNI'
[ "$prune_istiod_line" -lt "$prune_base_line" ] || fail 'Istio base was pruned before istiod'
[ "$prune_base_line" -lt "$prune_namespace_line" ] || fail 'namespaces were pruned before their resources'
grep -Fq 'bootstrap manifests removed in reverse order' "$fixture_dir/prune-output" ||
  fail 'prune omitted its completion boundary'

printf 'Bootstrap and prune script fixtures passed\n'
