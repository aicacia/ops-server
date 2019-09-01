#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

helm delete --purge metallb
kubectl_with_environment delete $dir/metallb.yaml

helm delete --purge nginx-ingress