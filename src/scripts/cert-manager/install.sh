#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml

helm repo add jetstack https://charts.jetstack.io

helm install jetstack/cert-manager \
  --name cert-manager \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME \
  --set letsencrypt.email=$LETS_ENCRYPT_EMAIL

wait_for_deployment "cert-manager" "ci"