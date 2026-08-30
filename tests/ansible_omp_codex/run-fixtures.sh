#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export ANSIBLE_CONFIG="$repo_root/ansible.cfg"
export ANSIBLE_ROLES_PATH="$repo_root/ansible/roles"
export PATH="$repo_root/bin:$PATH"

inventory="$repo_root/tests/ansible_omp_codex/inventory.yml"
preflight="$repo_root/tests/ansible_omp_codex/preflight.yml"
rendered_contract="$repo_root/tests/ansible_omp_codex/rendered_contract.yml"
gateway_wrapper="$repo_root/ansible/roles/omp_codex/files/omp-auth-gateway-exec"
credential_fixture="$(mktemp -d)"

cleanup() {
  rm -rf "$credential_fixture"
}
trap cleanup EXIT

run_rejected() {
  local label="$1"
  local extra_vars="$2"

  if ansible-playbook -i "$inventory" "$preflight" --extra-vars "$extra_vars" >/dev/null 2>&1; then
    printf 'Expected OMP fixture to reject %s\n' "$label" >&2
    return 1
  fi
  printf 'Rejected %s\n' "$label"
}

ansible-playbook -i "$inventory" "$preflight" >/dev/null
ansible-playbook -i "$inventory" "$preflight" --extra-vars \
  '{"omp_codex_rotate_gateway_token":true,"omp_codex_mutation_authorization":"ROTATE OMP GATEWAY TOKEN"}' >/dev/null
printf '%s\n' 'Accepted exactly authorized gateway-token rotation'
ansible-playbook -i "$inventory" "$rendered_contract" >/dev/null

if CREDENTIALS_DIRECTORY="$credential_fixture" "$gateway_wrapper" /usr/bin/true >/dev/null 2>&1; then
  printf '%s\n' 'Expected gateway wrapper to reject a missing broker credential' >&2
  exit 1
fi
touch "$credential_fixture/broker-token"
if CREDENTIALS_DIRECTORY="$credential_fixture" "$gateway_wrapper" /usr/bin/true >/dev/null 2>&1; then
  printf '%s\n' 'Expected gateway wrapper to reject an empty broker credential' >&2
  exit 1
fi
printf '%s\n' 'fixture-broker-token' >"$credential_fixture/broker-token"
# The nested shell, not this runner, expands the credential environment.
# shellcheck disable=SC2016
CREDENTIALS_DIRECTORY="$credential_fixture" "$gateway_wrapper" /bin/sh -c \
  '[ "$OMP_AUTH_BROKER_TOKEN" = fixture-broker-token ]'
printf '%s\n' 'Gateway systemd credential wrapper passed'

run_rejected 'non-ARM64 host' '{"ansible_architecture":"x86_64"}'
run_rejected 'unreviewed OMP version' '{"omp_codex_version":"18.0.9"}'
run_rejected 'wrong OMP checksum' '{"omp_codex_linux_arm64_sha256":"0000000000000000000000000000000000000000000000000000000000000000"}'
run_rejected 'public broker listener' '{"omp_codex_broker_bind_address":"0.0.0.0"}'
run_rejected 'broad gateway listener' '{"omp_codex_gateway_bind_address":"0.0.0.0"}'
run_rejected 'gateway address absent from host' '{"omp_codex_gateway_bind_address":"192.0.2.11"}'
run_rejected 'missing gateway bearer requirement' '{"omp_codex_gateway_auth_required":false}'
run_rejected 'missing gateway source CIDR' '{"omp_codex_gateway_allowed_cidrs":[]}'
run_rejected 'world-wide gateway source CIDR' '{"omp_codex_gateway_allowed_cidrs":["0.0.0.0/0"]}'
run_rejected 'unsafe broker state mode' '{"omp_codex_broker_state_mode":"0755"}'
run_rejected 'unsafe gateway token mode' '{"omp_codex_gateway_token_mode":"0644"}'
run_rejected 'unexpected workload projection GID' '{"omp_codex_gateway_client_gid":24041}'
run_rejected 'world-readable workload bearer' '{"omp_codex_gateway_client_token_mode":"0644"}'
run_rejected 'legacy unauthenticated mode' '{"omp_codex_gateway_no_auth":true}'
run_rejected 'legacy unbounded mode' '{"omp_codex_allow_unbounded":true}'
run_rejected 'unauthorized gateway-token rotation' '{"omp_codex_rotate_gateway_token":true}'
run_rejected 'wrong gateway-token authorization' '{"omp_codex_rotate_gateway_token":true,"omp_codex_mutation_authorization":"ROTATE TOKEN"}'
run_rejected 'multiple credential mutations' '{"omp_codex_rotate_gateway_token":true,"omp_codex_revoke_openai_codex":true,"omp_codex_mutation_authorization":"ROTATE OMP GATEWAY TOKEN"}'
run_rejected 'stale mutation authorization' '{"omp_codex_mutation_authorization":"ROTATE OMP GATEWAY TOKEN"}'

printf 'OMP Codex boundary fixtures passed\n'
