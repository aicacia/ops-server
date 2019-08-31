#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../../functions.sh

helm delete --purge nginx-ingress
kubectl_with_environment delete $dir/metallb-config.yaml
kubectl delete -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
