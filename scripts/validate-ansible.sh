#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

: "${ANSIBLE_CONFIG:=$repo_root/ansible.cfg}"
export ANSIBLE_CONFIG

ansible-lint ansible/playbooks ansible/roles
for playbook in ansible/playbooks/*.yaml ansible/playbooks/*.yml; do
  ansible-playbook --syntax-check "$playbook"
done

echo "Ansible lifecycle static validation passed"
