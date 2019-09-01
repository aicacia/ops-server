#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=cert-manager

source $dir/../../functions.sh

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

kubectl_with_environment "apply" "$dir/letsencrypt-prod.yaml"
kubectl_with_environment "apply" "$dir/letsencrypt-staging.yaml"

kubectl create namespace ${namespace}
kubectl label namespace ${namespace} certmanager.k8s.io/disable-validation="true"

helm repo add jetstack https://charts.jetstack.io

helm install jetstack/cert-manager \
  --name cert-manager \
  --namespace ${namespace} \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME

wait_for_deployment "cert-manager" ${namespace}