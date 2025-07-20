#!/usr/bin/env bash
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

if [[ ! -f ".env" ]]; then
    echo "'.env' file not found."
    exit 1
fi

source .env

if [[ ! $(kubectl get ns scylladb) ]]; then
    kubectl create ns scylladb
fi

kubectl apply -f configmap.yaml -n scylladb

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install --upgrade ${RELEASE_NAME}-scylladb bitnami/scylladb \
    --version 5.0.1 \
    -n scylladb \
    -f values.yaml \
    --set dbUser.user="${SCYLLA_USERNAME}" \
    --set dbUser.password="${SCYLLA_PASSWORD}"