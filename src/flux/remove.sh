#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
flux_name=flux
helm_operator_name=helm-operator
namespace=flux

source $dir/../functions.sh

helm delete ${flux_name} --namespace ${namespace}
helm delete ${helm_operator_name} --namespace ${namespace}
kubectl delete namespace ${namespace}
helm repo remove fluxcd

kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml