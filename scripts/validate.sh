#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
export PATH="$REPO_ROOT/bin:$PATH"
cd "$REPO_ROOT"

required_tools=(actionlint helm kubeconform kustomize shellcheck yq)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Error: required tool %s is unavailable. Run source bin/activate-hermit.\n' "$tool" >&2
    exit 1
  fi
done

actionlint
shellcheck -x scripts/*.sh
ARGOCD_GITHUB_REPO=https://github.com/nandiheath/homelab-public.git \
ARGOCD_GITHUB_ORG=https://github.com/nandiheath \
VAULT=homelab \
ARGOCD_ADMIN_GITHUB_USER=nandiheath \
HOMELAB_RENDER_CANONICAL=true \
  ./scripts/render.sh --all --infra
kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  artifacts/
