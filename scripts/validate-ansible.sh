#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

: "${ANSIBLE_CONFIG:=$repo_root/ansible.cfg}"
export ANSIBLE_CONFIG
export PATH="$repo_root/bin:$PATH"

required_tools=(ansible ansible-playbook ansible-lint jq shellcheck ssh-keygen)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Required lifecycle validation tool is unavailable: %s\n' "$tool" >&2
    exit 1
  fi
done

if [[ "$(ansible --version | sed -n '1p')" != 'ansible [core 2.21.2]' ]]; then
  printf 'ansible-core must be exactly 2.21.2\n' >&2
  exit 1
fi
if [[ "$(ansible-lint --version)" != ansible-lint\ 26.6.0* ]]; then
  printf 'ansible-lint must be exactly 26.6.0\n' >&2
  exit 1
fi

for task_file in tasks/planned/*.md; do
  grep -qx -- '- Status: planned' "$task_file"
  grep -qx -- '- Owner: unassigned' "$task_file"
done
for task_file in tasks/running/*.md; do
  grep -Eqx -- '- Status: (running|blocked|ready-for-rollup)' "$task_file"
  if grep -qx -- '- Owner: unassigned' "$task_file"; then
    printf 'Running task has no owner: %s\n' "$task_file" >&2
    exit 1
  fi
done

shellcheck scripts/validate-ansible.sh tests/ansible_lifecycle/run-fixtures.sh
ansible-lint ansible/playbooks ansible/roles tests/ansible_lifecycle/operation_guard.yml
for playbook in ansible/playbooks/*.yaml ansible/playbooks/*.yml; do
  ansible-playbook --syntax-check "$playbook"
done
ansible-playbook -i tests/ansible_lifecycle/inventory.yml --syntax-check \
  tests/ansible_lifecycle/operation_guard.yml \
  -e fixture_host_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFixtureSyntaxCheckOnly' \
  -e fixture_known_hosts_file=/dev/null

tests/ansible_lifecycle/run-fixtures.sh
printf 'Ansible lifecycle validation passed\n'
