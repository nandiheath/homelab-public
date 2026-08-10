#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
export PATH="$REPO_ROOT/bin:$PATH"
cd "$REPO_ROOT"

required_tools=(actionlint helm homelab kubeconform kustomize shellcheck yq)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Error: required tool %s is unavailable. Run source bin/activate-hermit.\n' "$tool" >&2
    exit 1
  fi
done

if [[ "$(homelab version)" != "0.5.0" ]]; then
  printf 'Error: homelab 0.5.0 is required by the shared render and lifecycle contract.\n' >&2
  exit 1
fi

actionlint
shellcheck -x scripts/*.sh tests/bootstrap/*.sh
kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  artifacts/
