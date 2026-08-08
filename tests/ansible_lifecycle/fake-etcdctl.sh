#!/bin/sh
set -eu

args=$*
printf 'etcd|%s\n' "$args" >>"${FIXTURE_COMMAND_LOG:?}"
case "$args" in
  *" endpoint status "*)
    printf '%s\n' '[{"Endpoint":"node-0","Status":{"version":"3.6.12-k3s1"}},{"Endpoint":"node-1","Status":{"version":"3.6.12-k3s1"}},{"Endpoint":"node-2","Status":{"version":"3.6.12-k3s1"}}]'
    ;;
  *" member list "*)
    printf '%s\n' '{"members":[{"name":"node-0","isLearner":false},{"name":"node-1","isLearner":false},{"name":"node-2","isLearner":false}]}'
    ;;
  *)
    exit 2
    ;;
esac
