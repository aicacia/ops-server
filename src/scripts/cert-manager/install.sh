#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../init.sh

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

kubectl_with_environment "apply" "$dir/letsencrypt-prod.yaml"
kubectl_with_environment "apply" "$dir/letsencrypt-staging.yaml"

kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"

helm repo add jetstack https://charts.jetstack.io

helm install jetstack/cert-manager \
  --name cert-manager \
  --namespace cert-manager \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME

wait_for_deployment "cert-manager" "cert-manager"