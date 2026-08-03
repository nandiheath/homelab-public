#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fixture_dir="$repo_root/tests/ansible_lifecycle"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ansible-lifecycle.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

ssh-keygen -q -t ed25519 -N '' -f "$tmp_dir/host_key"
fixture_host_key="$(cat "$tmp_dir/host_key.pub")"
known_hosts="$tmp_dir/known_hosts"
for address in 192.0.2.11 192.0.2.12 192.0.2.13; do
  printf '%s %s\n' "$address" "$fixture_host_key" >>"$known_hosts"
done
chmod 0600 "$known_hosts"
jq -n \
  --arg fixture_host_key "$fixture_host_key" \
  --arg fixture_known_hosts_file "$known_hosts" \
  '{fixture_host_key: $fixture_host_key, fixture_known_hosts_file: $fixture_known_hosts_file}' \
  >"$tmp_dir/fixture-vars.json"

base=(
  ansible-playbook
  -i "$fixture_dir/inventory.yml"
  "$fixture_dir/operation_guard.yml"
  -e "@$tmp_dir/fixture-vars.json"
)
network_base=(
  ansible-playbook
  -i "$fixture_dir/inventory.yml"
  "$fixture_dir/k3s_network_contract.yml"
  -e "@$tmp_dir/fixture-vars.json"
)
case_output="$tmp_dir/case-output"

run_guard() {
  local operation="$1"
  local source="$2"
  local target="$3"
  local confirmation="$4"
  shift 4
  FIXTURE_OPERATION="$operation" \
  FIXTURE_SOURCE_VERSION="$source" \
  FIXTURE_TARGET_VERSION="$target" \
  FIXTURE_CONFIRMATION="$confirmation" \
    "${base[@]}" "$@"
}

expect_accept() {
  local label="$1"
  shift
  if ! run_guard "$@" >"$case_output" 2>&1; then
    cat "$case_output" >&2
    printf 'Expected accepted lifecycle case failed: %s\n' "$label" >&2
    exit 1
  fi
  if ! grep -q 'LIFECYCLE_MUTATION_SENTINEL_REACHED' "$case_output"; then
    cat "$case_output" >&2
    printf 'Accepted lifecycle case missed sentinel: %s\n' "$label" >&2
    exit 1
  fi
}

expect_reject() {
  local label="$1"
  shift
  if run_guard "$@" >"$case_output" 2>&1; then
    cat "$case_output" >&2
    printf 'Expected rejected lifecycle case succeeded: %s\n' "$label" >&2
    exit 1
  fi
  if grep -q 'LIFECYCLE_MUTATION_SENTINEL_REACHED' "$case_output"; then
    cat "$case_output" >&2
    printf 'Rejected lifecycle case reached sentinel: %s\n' "$label" >&2
    exit 1
  fi
}
run_network_contract() {
  "${network_base[@]}" "$@"
}

expect_network_accept() {
  local label="$1"
  shift
  if ! run_network_contract "$@" >"$case_output" 2>&1; then
    cat "$case_output" >&2
    printf 'Expected accepted K3s network case failed: %s\n' "$label" >&2
    exit 1
  fi
  if ! grep -q 'K3S_INSTALLER_MUTATION_SENTINEL_REACHED' "$case_output"; then
    cat "$case_output" >&2
    printf 'Accepted K3s network case missed sentinel: %s\n' "$label" >&2
    exit 1
  fi
}

expect_network_reject() {
  local label="$1"
  shift
  if run_network_contract "$@" >"$case_output" 2>&1; then
    cat "$case_output" >&2
    printf 'Expected rejected K3s network case succeeded: %s\n' "$label" >&2
    exit 1
  fi
  if grep -q 'K3S_INSTALLER_MUTATION_SENTINEL_REACHED' "$case_output"; then
    cat "$case_output" >&2
    printf 'Rejected K3s network case reached sentinel: %s\n' "$label" >&2
    exit 1
  fi
}

operations=(
  'reset|v1.36.2+k3s1|v1.36.2+k3s1|RESET homelab-production AND DESTROY ALL KUBERNETES DATA'
  'kernel_activation|v1.36.2+k3s1|v1.36.2+k3s1|ACTIVATE KERNEL 5.15.0-1105-raspi ON homelab-production'
  'k3s_install|v1.36.2+k3s1|v1.36.2+k3s1|INSTALL K3S v1.36.2+k3s1 ON homelab-production'
  'bootstrap_network|v1.36.2+k3s1|v1.36.2+k3s1|BOOTSTRAP NETWORK homelab-production'
  'bootstrap_gitops|v1.36.2+k3s1|v1.36.2+k3s1|BOOTSTRAP homelab-production'
)

for fixture_case in "${operations[@]}"; do
  IFS='|' read -r operation source target confirmation <<<"$fixture_case"
  expect_accept "$operation exact authorization" "$operation" "$source" "$target" "$confirmation"
  expect_reject "$operation missing authorization" "$operation" "$source" "$target" ''
  expect_reject "$operation boolean authorization" "$operation" "$source" "$target" "$confirmation" -e '{"operation_guard_confirmation":true}'
  expect_reject "$operation wrong cluster" "$operation" "$source" "$target" "$confirmation" -e cluster_id=stale-production
  expect_reject "$operation wrong authorization" "$operation" "$source" "$target" 'NOT AUTHORIZED'
done

expect_reject 'direct install wrong source' k3s_install v1.36.1+k3s1 v1.36.1+k3s1 'INSTALL K3S v1.36.1+k3s1 ON homelab-production'
expect_reject 'direct install wrong target' k3s_install v1.36.3+k3s1 v1.36.3+k3s1 'INSTALL K3S v1.36.3+k3s1 ON homelab-production'
expect_reject 'upgrade path disabled' k3s_upgrade v1.36.2+k3s1 v1.36.2+k3s1 'UPGRADE homelab-production FROM v1.36.2+k3s1 TO v1.36.2+k3s1'
expect_network_accept 'valid explicit contract'
expect_network_reject 'missing cluster CIDR' -e cluster_cidr=
expect_network_reject 'malformed cluster CIDR' -e cluster_cidr=10.244.0.0/33
expect_network_reject 'malformed service CIDR' -e service_cidr=not-a-cidr
expect_network_reject 'overlapping cluster and service CIDRs' -e service_cidr=10.244.128.0/17
expect_network_reject 'cluster DNS outside service CIDR' -e cluster_dns=10.97.0.10
expect_network_reject \
  'server IP inside service CIDR' \
  -e service_cidr=192.0.2.0/24 \
  -e cluster_dns=192.0.2.10
expect_network_reject \
  'defined legacy server arguments' \
  -e '{"extra_server_args":"--token plaintext"}'
expect_network_reject \
  'role-owned server argument override' \
  -e '{"k3s_server_common_args":["--cluster-init","--server","https://example.invalid","--token","plaintext"]}'

printf 'Ansible lifecycle fixtures passed\n'
