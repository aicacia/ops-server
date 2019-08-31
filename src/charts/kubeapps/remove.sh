#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

helm repo remove bitnami
helm delete --purge kubeapps

kubectl delete serviceaccount kubeapps-operator -n ${tiller_namespace}
kubectl delete clusterrolebinding kubeapps-operator -n ${tiller_namespace}