#!/usr/bin/env bash
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

if [[ ! -f ".env" ]]; then
    echo "'.env' file not found."
    exit 1
fi

source .env

if [[ ! $(kubectl get ns rabbitmq) ]]; then
    kubectl create ns rabbitmq
fi

helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install ${RELEASE_NAME}-rabbitmq bitnami/rabbitmq \
    --version 16.0.11 \
    -n rabbitmq \
    -f values.yaml \
    --set auth.username="${RABBITMQ_USER}" \
    --set auth.password="${RABBITMQ_PASSWORD}"
