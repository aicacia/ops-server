#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
flux_name=flux
helm_operator_name=helm-operator
namespace=flux
sealed_secrets_version=0.9.7

source $dir/../functions.sh

helm delete ${flux_name} --namespace ${namespace}
helm delete ${helm_operator_name} --namespace ${namespace}
kubectl delete namespace ${namespace}
helm repo remove fluxcd
kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml

rm /usr/local/bin/kubeseal
kubectl delete -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/controller.yaml