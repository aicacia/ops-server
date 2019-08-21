#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

#helm repo add jetstack https://charts.jetstack.io

#helm install jetstack/cert-manager \
helm install stable/cert-manager \
  --name cert-manager \
  --namespace ci \
  --version v0.6.0 \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME \
  --set letsencrypt.email=$LETS_ENCRYPT_EMAIL

wait_for_deployment "cert-manager" "ci"