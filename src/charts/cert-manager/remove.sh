#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=cert-manager

source $dir/../../functions.sh

helm uninstall cert-manager -n ${namespace}
helm repo remove jetstack

kubectl_with_environment "delete" "$dir/letsencrypt-prod.yaml" "-n ${namespace}"
kubectl_with_environment "delete" "$dir/letsencrypt-staging.yaml" "-n ${namespace}"

kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml

kubectl label namespace ${namespace} certmanager.k8s.io/disable-validation="false" --overwrite
kubectl delete namespace ${namespace}