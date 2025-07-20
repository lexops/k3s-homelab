#!/usr/bin/env bash
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

if [[ ! -f ".env" ]]; then
    echo "'.env' file not found."
    exit 1
fi

source .env

helm repo add meilisearch-kubernetes https://meilisearch.github.io/meilisearch-kubernetes
helm upgrade --install ${RELEASE_NAME}-meilisearch meilisearch-kubernetes/meilisearch \
    --version 0.14.0 \
    --create-namespace \
    -n meilisearch \
    -f values.yaml \
    --set environment.MEILI_MASTER_KEY=${MEILI_MASTER_KEY}