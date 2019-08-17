#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

helm install stable/kubernetes-dashboard \
  --name kubernetes-dashboard \
  --namespace ci \
  --values $dir/values.yaml

wait_for_deployment "kubernetes-dashboard" "ci"

kubectl -n ci describe secrets kubernetes-dashboard-token