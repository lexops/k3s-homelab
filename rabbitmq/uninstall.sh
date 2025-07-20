#!/usr/bin/env bash
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

helm uninstall ${RELEASE_NAME}-rabbitmq -n rabbitmq

kubectl delete ns rabbitmq