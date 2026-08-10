#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
script="$repo_root/scripts/bootstrap.sh"
fixture_dir=$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-fixture.XXXXXX")
trap 'rm -rf "$fixture_dir"' EXIT
fixture_log="$fixture_dir/kubectl.log"
fixture_state="$fixture_dir/state"
private_repository="$fixture_dir/homelab-private"
mkdir -p "$fixture_state" "$private_repository/bootstrap/resources"
touch \
  "$private_repository/bootstrap/application-homelab-bootstrap.yaml" \
  "$private_repository/bootstrap/resources/application-cilium.yaml" \
  "$private_repository/bootstrap/resources/application-homelab-private.yaml" \
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

plan=$($script --dry-run --private-repository "$private_repository")
printf '%s\n' "$plan" | grep -Fq 'Apply and verify Istio base, istiod, Istio CNI, and ztunnel.' ||
  fail 'dry-run omits the staged Istio data plane'
printf '%s\n' "$plan" | grep -Fq 'Apply and restart Argo CD after the healthy Istio data plane exists.' ||
  fail 'dry-run omits the post-Istio Argo CD stage'
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

if "$script" --private-repository "$private_repository" --authorize 'BOOTSTRAP wrong' >"$fixture_dir/wrong-auth.out" 2>&1; then
  fail 'wrong live authorization unexpectedly succeeded'
fi
grep -Fq 'authorization must be exactly: BOOTSTRAP homelab-production' \
  "$fixture_dir/wrong-auth.out" || fail 'wrong authorization did not fail closed'

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
esac
FAKE
chmod 0700 "$fixture_dir/kubectl"

BOOTSTRAP_FIXTURE_LOG=$fixture_log \
BOOTSTRAP_FIXTURE_STATE=$fixture_state \
  "$script" \
  --kubectl "$fixture_dir/kubectl" \
  --kubeconfig "$fixture_dir/kubeconfig" \
  --private-repository "$private_repository" \
  --cluster-id fixture \
  --authorize 'BOOTSTRAP fixture' >"$fixture_dir/output"

istiod_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istiod/')
ztunnel_line=$(line_of "$fixture_log" '/artifacts/infrastructure/istio-ztunnel/')
argocd_line=$(line_of "$fixture_log" '/artifacts/infrastructure/argocd/')
public_root_line=$(line_of "$fixture_log" '/artifacts/infrastructure/bootstrap/')
private_root_line=$(line_of "$fixture_log" '/bootstrap/application-homelab-bootstrap.yaml')
[ "$istiod_line" -lt "$ztunnel_line" ] || fail 'ztunnel was applied before istiod'
[ "$ztunnel_line" -lt "$argocd_line" ] || fail 'Argo CD was applied before ztunnel'
[ "$argocd_line" -lt "$public_root_line" ] || fail 'the public root was applied before Argo CD'
[ "$public_root_line" -lt "$private_root_line" ] || fail 'private ownership was applied before the public root'

grep -Fq 'label namespace argocd istio.io/dataplane-mode-' "$fixture_log" ||
  fail 'Argo CD recovery did not remove ambient enrollment'
grep -Fq 'label namespace istio-system istio.io/dataplane-mode-' "$fixture_log" ||
  fail 'Istio recovery did not remove ambient enrollment'
grep -Fq 'bootstrap completed: Istio preceded Argo CD' "$fixture_dir/output" ||
  fail 'successful bootstrap omitted the verified completion boundary'

printf 'Bootstrap script fixtures passed\n'
