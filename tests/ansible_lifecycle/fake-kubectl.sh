#!/bin/sh
set -eu

args=$*
phase=read
case "$args" in
  *" apply -f "*/artifacts/infrastructure/cluster-namespaces/namespace_*.yml) phase=namespaces ;;
  *" apply -f "*/artifacts/infrastructure/argocd*) phase=controllers ;;
  *" apply -f "*/artifacts/infrastructure/external-secrets*) phase=controllers ;;
  *" apply -f "*/artifacts/infrastructure/1password-connect*) phase=controllers ;;
  *" apply -f "*appproject-homelab-private.yaml*) phase=project ;;
  *" apply -f "*application_infrastructure-app-of-apps.yml*) phase=public-root ;;
  *" apply -f "*application-cilium.yaml*) phase=cilium ;;
  *" apply -f "*application-homelab-private.yaml*) phase=private-root ;;
  *" apply -f "*application-homelab-bootstrap.yaml*) phase=ownership-root ;;
  *" apply -f "*) phase=credentials ;;
esac
printf '%s|%s\n' "$phase" "$args" >>"${FIXTURE_COMMAND_LOG:?}"
if [ "${FIXTURE_FAIL_PHASE:-}" = "$phase" ]; then
  exit 70
fi

case "$args" in
  "version --client --output=yaml")
    printf '%s\n' 'clientVersion:' '  gitVersion: v1.35.2'
    ;;
  *" config current-context")
    printf '%s\n' homelab
    ;;
  *" config view --minify -o jsonpath={.clusters[0].cluster.server}")
    printf '%s' 'https://198.51.100.10:6443'
    ;;
  *" get nodes --output=json")
    printf '%s\n' '{"items":[{"metadata":{"name":"node-0"},"spec":{},"status":{"nodeInfo":{"kubeletVersion":"v1.36.2+k3s1"},"conditions":[{"type":"Ready","status":"True"}]}},{"metadata":{"name":"node-1"},"spec":{},"status":{"nodeInfo":{"kubeletVersion":"v1.36.2+k3s1"},"conditions":[{"type":"Ready","status":"True"}]}},{"metadata":{"name":"node-2"},"spec":{},"status":{"nodeInfo":{"kubeletVersion":"v1.36.2+k3s1"},"conditions":[{"type":"Ready","status":"True"}]}}]}'
    ;;
  *" version --output=json")
    printf '%s\n' '{"clientVersion":{"gitVersion":"v1.35.2"},"serverVersion":{"gitVersion":"v1.36.2+k3s1"}}'
    ;;
  *" get --raw=/readyz?verbose")
    printf '%s\n' '[+]etcd ok' 'readyz check ok'
    ;;
  *" get pods --all-namespaces --output=json")
    printf '%s\n' '{"items":[]}'
    ;;
  *" --namespace kube-system get daemonset cilium --output=json")
    printf '%s\n' '{"status":{"desiredNumberScheduled":3,"currentNumberScheduled":3,"numberReady":3,"numberAvailable":3,"updatedNumberScheduled":3}}'
    ;;
  *" get applications.argoproj.io --all-namespaces --output=json")
    printf '%s\n' '{"items":[]}'
    ;;
  *" get pvc --all-namespaces --output=json")
    printf '%s\n' '{"items":[]}'
    ;;
  *" get configmap cilium-config --output=json")
    printf '%s\n' '{"data":{"hubble-disable-tls":"false"}}'
    ;;
  *" get certificates.cert-manager.io hubble-server-certs --output=name")
    printf '%s\n' 'certificate.cert-manager.io/hubble-server-certs'
    ;;
  *" get application homelab-bootstrap --output=json")
    printf '%s\n' '{"status":{"resources":[{"kind":"AppProject","name":"homelab-private"},{"kind":"Application","name":"cilium"},{"kind":"Application","name":"homelab-private"}]}}'
    ;;
  *)
    ;;
esac
