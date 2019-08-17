#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

helm install stable/nginx-ingress \
  --name nginx-ingress \
  --namespace ingress \
  --values $dir/values.yaml

wait_for_deployment "nginx-ingress-controller" "ingress"