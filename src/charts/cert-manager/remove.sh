#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

helm delete --purge cert-manager
helm repo remove jetstack

kubectl_with_environment "delete" "$dir/letsencrypt-prod.yaml"
kubectl_with_environment "delete" "$dir/letsencrypt-staging.yaml"

kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml

kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="false" --overwrite

kubectl delete namespace cert-manager