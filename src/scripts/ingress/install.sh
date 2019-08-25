#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../init.sh

helm install stable/nginx-ingress \
  --name nginx-ingress \
  --namespace kube-system \
  --values $dir/values.yaml

wait_for_deployment "nginx-ingress-controller" "kube-system"