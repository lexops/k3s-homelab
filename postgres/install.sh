#!/usr/bin/env bash
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

if [[ ! -f ".env" ]]; then
    echo "'.env' file not found."
    exit 1
fi

source .env

if [[ ! $(kubectl get ns postgres) ]]; then
    kubectl create ns postgres
fi

helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install ${RELEASE_NAME}-postgres bitnami/postgresql \
    --version 16.7.20 \
    -n postgres \
    -f values.yaml \
    --set auth.username="${POSTGRES_USER}" \
    --set auth.password="${POSTGRES_PASSWORD}"
