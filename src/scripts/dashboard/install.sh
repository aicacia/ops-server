#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

helm install stable/kubernetes-dashboard \
  --name dashboard \
  --namespace kube-system \
  --set service.type=NodePort \
  --set service.nodePort=31000 \
  --set enableSkipLogin=true

# wait_for_deployment "dashboard" "kube-system"