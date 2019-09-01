#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

kubectl_with_environment delete $dir/metallb.yaml
kubectl delete -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl delete namespace metallb-system

helm delete --purge nginx-ingress