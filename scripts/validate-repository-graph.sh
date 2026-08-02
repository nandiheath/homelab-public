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
  find "$root/artifacts" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0 yq -r 'select(.kind == "Application") | [.metadata.name, .spec.source.repoURL, .spec.source.targetRevision, .spec.source.path] | @tsv'
}

while IFS=$'\t' read -r name repo revision path; do
  [[ -n "$name" ]] || continue
  [[ "$path" != manifests/* ]] || { printf '%s reads unrendered source: %s\n' "$name" "$path" >&2; exit 1; }
  case "$name" in
    homelab-private)
      [[ "$repo" == 'https://github.com/nandiheath/homelab-private.git' && "$revision" == main && "$path" == artifacts/application/application-app-of-apps ]] || {
        printf 'homelab-private source boundary is not exact\n' >&2; exit 1;
      }
      ;;
    *)
      [[ "$path" == artifacts/* && -d "$public_root/$path" ]] || { printf 'public Application %s has unresolved path %s\n' "$name" "$path" >&2; exit 1; }
      ;;
  esac
done < <(applications "$public_root")

while IFS=$'\t' read -r name repo revision path; do
  [[ -n "$name" ]] || continue
  [[ "$path" == artifacts/* && "$path" != manifests/* && -d "$private_root/$path" ]] || {
    printf 'private Application %s has unresolved path %s\n' "$name" "$path" >&2; exit 1;
  }
done < <(applications "$private_root")

identities() {
  local root=$1
  find "$root/artifacts" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0 yq -r '[.apiVersion, .kind, (.metadata.namespace // ""), .metadata.name] | @tsv' | sort -u
}
if comm -12 <(identities "$public_root") <(identities "$private_root") | grep -q .; then
  printf 'public and private rendered resource identities overlap:\n' >&2
  comm -12 <(identities "$public_root") <(identities "$private_root") >&2
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
