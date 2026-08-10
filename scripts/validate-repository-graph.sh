#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 1 ]]; then
  printf 'usage: %s PRIVATE_REPOSITORY\n' "$0" >&2
  exit 2
fi

public_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
private_root=$(cd -- "$1" && pwd)
denylist="$private_root/scripts/public-denylist.txt"

command -v yq >/dev/null || { printf 'yq is required\n' >&2; exit 1; }
[[ -d "$public_root/artifacts" && -d "$private_root/artifacts" ]] || {
  printf 'both repositories must contain rendered artifacts\n' >&2
  exit 1
}
[[ -f "$denylist" ]] || { printf 'private denylist is missing: %s\n' "$denylist" >&2; exit 1; }

applications() {
  local root=$1
  {
    find "$root/artifacts" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0
    if [[ -d "$root/bootstrap" ]]; then
      find "$root/bootstrap" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0
    fi
  } |
    xargs -0 yq -r \
      'select(.kind == "Application") | [.metadata.name, .spec.source.repoURL, .spec.source.targetRevision, .spec.source.path] | @tsv'
}

while IFS=$'\t' read -r name repo revision path; do
  [[ -n "$name" ]] || continue
  [[ "$path" != argocd/* ]] || { printf '%s reads unrendered source: %s\n' "$name" "$path" >&2; exit 1; }
  case "$name" in
    cilium|private-aoa)
      printf 'private-owned Application %s must be absent from public artifacts\n' "$name" >&2
      exit 1
      ;;
    *)
      [[ "$path" == artifacts/* && -d "$public_root/$path" ]] || {
        printf 'public Application %s has unresolved path %s\n' "$name" "$path" >&2
        exit 1
      }
      ;;
  esac
done < <(applications "$public_root")

while IFS=$'\t' read -r name repo revision path; do
  [[ -n "$name" ]] || continue
  case "$name" in
    cilium)
      [[ "$repo" == 'https://github.com/nandiheath/homelab-private.git' && "$revision" == main && "$path" == artifacts/infrastructure/cilium && -d "$private_root/$path" ]] || {
        printf 'private Cilium source boundary is not exact\n' >&2
        exit 1
      }
      ;;
    private-aoa)
      [[ "$repo" == 'https://github.com/nandiheath/homelab-private.git' && "$revision" == main && "$path" == artifacts/application/private-aoa && -d "$private_root/$path" ]] || {
        printf 'private-aoa source boundary is not exact\n' >&2
        exit 1
      }
      ;;
    *)
      [[ "$path" == artifacts/* && "$path" != argocd/* && -d "$private_root/$path" ]] || {
        printf 'private Application %s has unresolved path %s\n' "$name" "$path" >&2
        exit 1
      }
      ;;
  esac
done < <(applications "$private_root")

# Cilium is a deliberately shared platform artifact. Its private derivation is
# validated separately by the private renderer against the pinned public source.
identities() {
  local root=$1
  {
    find "$root/artifacts" -type f \( -name '*.yaml' -o -name '*.yml' \) \
      ! -path "$root/artifacts/infrastructure/cilium/*" -print0
    if [[ -d "$root/bootstrap" ]]; then
      find "$root/bootstrap" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0
    fi
  } |
    xargs -0 yq -r \
      '[.apiVersion, .kind, (.metadata.namespace // ""), .metadata.name] | @tsv' |
    sort -u
}
if comm -12 <(identities "$public_root") <(identities "$private_root") | grep -q .; then
  printf 'public and private rendered resource identities overlap:\n' >&2
  comm -12 <(identities "$public_root") <(identities "$private_root") >&2
  exit 1
fi

private_project_count=$(
  find "$private_root/bootstrap" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 |
    xargs -0 yq -r 'select(.kind == "AppProject" and .metadata.name == "homelab-private") | .metadata.name' |
    wc -l |
    tr -d ' '
)
[[ "$private_project_count" == 1 ]] || {
  printf 'private bootstrap must contain exactly one homelab-private AppProject\n' >&2
  exit 1
}
if find "$public_root/artifacts" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 |
  xargs -0 yq -e 'select(.kind == "AppProject" and .metadata.name == "homelab-private")' >/dev/null 2>&1; then
  printf 'homelab-private AppProject must be absent from public artifacts\n' >&2
  exit 1
fi

while IFS= read -r literal; do
  [[ -z "$literal" || "$literal" == \#* ]] && continue
  if grep -R -F --exclude-dir=.git -- "$literal" "$public_root" >/dev/null; then
    printf 'public repository contains denied private literal: %s\n' "$literal" >&2
    exit 1
  fi
done < "$denylist"

printf 'rendered repository graph is valid\n'
