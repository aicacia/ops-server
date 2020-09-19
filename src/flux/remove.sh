#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
home_dir=$2
flux_name=flux
helm_operator_name=helm-operator
namespace=flux
sealed_secrets_version=0.12.5

source $dir/../functions.sh

export KUBECONFIG=${home_dir}/.kube/config

helm delete ${flux_name} --namespace ${namespace}
helm delete ${helm_operator_name} --namespace ${namespace}
kubectl delete namespace ${namespace}
helm repo remove fluxcd
kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml

rm /usr/local/bin/kubeseal
kubectl delete -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/controller.yaml