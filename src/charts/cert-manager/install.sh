#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=cert-manager
version=v0.12.0-beta.1

source $dir/../../functions.sh

kubectl create namespace ${namespace}
kubectl label namespace ${namespace} certmanager.k8s.io/disable-validation="true"

kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

kubectl_with_environment "apply" "$dir/letsencrypt-prod.yaml" "namespace ${namespace}"
kubectl_with_environment "apply" "$dir/letsencrypt-staging.yaml" "namespace ${namespace}"

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --version ${version} \
  --namespace ${namespace} \
  --values $dir/values.yaml \
  --set ingressShim.defaultIssuerName=$ISSUER_NAME

wait_for_deployment "cert-manager" ${namespace}