#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fixture_dir="$repo_root/tests/ansible_lifecycle"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ansible-entrypoints.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

ssh-keygen -q -t ed25519 -N '' -f "$tmp_dir/host_key"
fixture_host_key="$(cat "$tmp_dir/host_key.pub")"
known_hosts="$tmp_dir/known_hosts"
for address in 192.0.2.11 192.0.2.12 192.0.2.13; do
  printf '%s %s\n' "$address" "$fixture_host_key" >>"$known_hosts"
done
chmod 0600 "$known_hosts"
fixture_kubeconfig="$tmp_dir/kubeconfig"
: >"$fixture_kubeconfig"
chmod 0600 "$fixture_kubeconfig"

jq -n \
  --arg fixture_host_key "$fixture_host_key" \
  --arg fixture_known_hosts_file "$known_hosts" \
  '{fixture_host_key: $fixture_host_key, fixture_known_hosts_file: $fixture_known_hosts_file}' \
  >"$tmp_dir/fixture-vars.json"

export CONNECT_CREDENTIALS_CONTENT=fixture
export GITHUB_APP_CREDENTIALS_CONTENT=fixture

case_output="$tmp_dir/case-output"
base=(
  ansible-playbook
  -i "$fixture_dir/inventory.yml"
  -e "@$tmp_dir/fixture-vars.json"
)

assert_reject() {
  local label="$1"
  shift
  if "${base[@]}" "$@" >"$case_output" 2>&1; then
    cat "$case_output" >&2
    printf 'Expected entrypoint rejection succeeded: %s\n' "$label" >&2
    exit 1
  fi
  if ! grep -Eq 'Refusing lifecycle operation|Refusing destructive (reset|wipe)|missing, mistyped, stale|unsafe' "$case_output"; then
    cat "$case_output" >&2
    printf 'Entrypoint failed for an unexpected reason: %s\n' "$label" >&2
    exit 1
  fi
  if grep -q 'LIFECYCLE_MUTATION_SENTINEL_REACHED' "$case_output"; then
    cat "$case_output" >&2
    printf 'Rejected entrypoint reached mutation sentinel: %s\n' "$label" >&2
    exit 1
  fi
}

assert_tasks() {
  local label="$1"
  local expected="$2"
  shift 2
  local task_output
  if ! task_output=$("${base[@]}" "$@" --list-tasks 2>&1); then
    printf '%s\n' "$task_output" >&2
    printf 'Entrypoint task listing failed: %s\n' "$label" >&2
    exit 1
  fi
  if ! grep -Fq -- "$expected" <<<"$task_output"; then
    printf '%s\n' "$task_output" >&2
    printf 'Entrypoint transaction task is missing: %s\n' "$label" >&2
    exit 1
  fi
}

reset_preflight_connection="$(
  yq eval \
    '.[] | select(.name == "Recheck the live cluster immediately before reset authorization") | .connection // ""' \
    "$repo_root/ansible/playbooks/reset.yaml"
)"
if [[ -n "$reset_preflight_connection" ]]; then
  printf '%s\n' \
    'Reset preflight must inherit localhost locally while allowing delegated hosts to use inventory SSH connections.' >&2
  exit 1
fi

network_args=(
  -e "kubeconfig=$fixture_kubeconfig"
  -e controller_kubectl=/bin/false
  -e "private_cilium_artifact=$repo_root/artifacts/infrastructure/cilium"
  -e "public_cilium_artifact=$repo_root/artifacts/infrastructure/cilium"
  -e api_endpoint=198.51.100.10
  -e cluster_cidr=198.18.0.0/16
  -e service_cidr=198.19.0.0/16
  -e cluster_dns=198.19.0.10
)
reset_args=(-l localhost -e "kubeconfig=$fixture_kubeconfig" -e controller_kubectl=/bin/false)

# Every actual mutating entrypoint must reject missing and wrong authorization
# before contacting a managed host or entering its mutation transaction.
assert_reject 'kernel missing authorization' ansible/playbooks/kernel_upgrade.yaml
assert_reject 'kernel wrong authorization' ansible/playbooks/kernel_upgrade.yaml -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'kernel boolean authorization' ansible/playbooks/kernel_upgrade.yaml -e '{"operation_guard_confirmation":true}'
assert_reject 'kernel stale cluster' ansible/playbooks/kernel_upgrade.yaml -e cluster_id=stale-production

assert_reject 'reboot missing authorization' ansible/playbooks/reboot.yaml
assert_reject 'reboot wrong authorization' ansible/playbooks/reboot.yaml -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'reboot boolean authorization' ansible/playbooks/reboot.yaml -e '{"operation_guard_confirmation":true}'
assert_reject 'reboot stale cluster' ansible/playbooks/reboot.yaml -e cluster_id=stale-production

assert_reject 'install missing authorization' ansible/playbooks/install.yaml
assert_reject 'install wrong authorization' ansible/playbooks/install.yaml -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'install boolean authorization' ansible/playbooks/install.yaml -e '{"operation_guard_confirmation":true}'
assert_reject 'install stale cluster' ansible/playbooks/install.yaml -e cluster_id=stale-production

upgrade_common=(
  -e upgrade_source_version=v1.36.2+k3s1
  -e upgrade_target_version=v1.36.2+k3s1
)
assert_reject 'upgrade missing authorization' ansible/playbooks/upgrade.yaml "${upgrade_common[@]}"
assert_reject 'upgrade wrong authorization' ansible/playbooks/upgrade.yaml "${upgrade_common[@]}" -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'upgrade boolean authorization' ansible/playbooks/upgrade.yaml "${upgrade_common[@]}" -e '{"operation_guard_confirmation":true}'
assert_reject 'upgrade stale cluster' ansible/playbooks/upgrade.yaml "${upgrade_common[@]}" -e cluster_id=stale-production
assert_reject 'upgrade wrong source' ansible/playbooks/upgrade.yaml -e upgrade_source_version=v1.36.1+k3s1 -e upgrade_target_version=v1.36.2+k3s1 -e 'operation_guard_confirmation=UPGRADE fixture-cluster FROM v1.36.1+k3s1 TO v1.36.2+k3s1'
assert_reject 'upgrade wrong target' ansible/playbooks/upgrade.yaml -e upgrade_source_version=v1.36.2+k3s1 -e upgrade_target_version=v1.36.3+k3s1 -e 'operation_guard_confirmation=UPGRADE fixture-cluster FROM v1.36.2+k3s1 TO v1.36.3+k3s1'

assert_reject 'reset missing authorization' ansible/playbooks/reset.yaml "${reset_args[@]}"
assert_reject 'reset wrong authorization' ansible/playbooks/reset.yaml "${reset_args[@]}" -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'reset boolean authorization' ansible/playbooks/reset.yaml "${reset_args[@]}" -e '{"operation_guard_confirmation":true}'
assert_reject 'reset stale cluster' ansible/playbooks/reset.yaml "${reset_args[@]}" -e cluster_id=stale-production

assert_reject 'network missing authorization' ansible/playbooks/bootstrap_network.yaml "${network_args[@]}"
assert_reject 'network wrong authorization' ansible/playbooks/bootstrap_network.yaml "${network_args[@]}" -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'network boolean authorization' ansible/playbooks/bootstrap_network.yaml "${network_args[@]}" -e '{"operation_guard_confirmation":true}'
assert_reject 'network stale cluster' ansible/playbooks/bootstrap_network.yaml "${network_args[@]}" -e cluster_id=stale-production

assert_reject 'GitOps missing authorization' ansible/playbooks/bootstrap_gitops.yml -e "kubeconfig=$fixture_kubeconfig"
assert_reject 'GitOps wrong authorization' ansible/playbooks/bootstrap_gitops.yml -e "kubeconfig=$fixture_kubeconfig" -e 'operation_guard_confirmation=NOT AUTHORIZED'
assert_reject 'GitOps boolean authorization' ansible/playbooks/bootstrap_gitops.yml -e "kubeconfig=$fixture_kubeconfig" -e '{"operation_guard_confirmation":true}'
assert_reject 'GitOps stale cluster' ansible/playbooks/bootstrap_gitops.yml -e "kubeconfig=$fixture_kubeconfig" -e cluster_id=stale-production

# Accepted entrypoints are listed without execution; the existing operation
# guard fixture separately reaches its mutation sentinel for exact accepted
# authorization. This proves the real playbooks include their transaction work.
assert_tasks 'kernel transaction' 'Reboot each node into the pinned kernel' ansible/playbooks/kernel_upgrade.yaml
assert_tasks 'reboot transaction' 'Reboot node after pinned kernel installation' ansible/playbooks/reboot.yaml
assert_tasks 'install transaction' 'Install and verify one embedded-etcd server' ansible/playbooks/install.yaml
assert_tasks 'reset transaction' 'Uninstall the role-owned K3s installation' ansible/playbooks/reset.yaml "${reset_args[@]}"
assert_tasks 'network transaction' 'Apply temporary Cilium bootstrap artifact from controller' ansible/playbooks/bootstrap_network.yaml "${network_args[@]}"
assert_tasks 'GitOps transaction' 'Apply GitOps controllers from controller' ansible/playbooks/bootstrap_gitops.yml -e "kubeconfig=$fixture_kubeconfig"

printf 'Lifecycle entrypoint fixtures passed\n'
