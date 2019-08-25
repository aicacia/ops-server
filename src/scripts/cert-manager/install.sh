#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

kubectl_with_environment apply "$dir/letsencrypt-prod.yaml"
kubectl_with_environment apply "$dir/letsencrypt-staging.yaml"

helm repo add jetstack https://charts.jetstack.io

helm install jetstack/cert-manager \
  --name cert-manager \
  --namespace kube-system \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME

wait_for_deployment "cert-manager" "kube-system"