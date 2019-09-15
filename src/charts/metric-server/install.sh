#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-system

source $dir/../../functions.sh

helm install stable/metrics-server \
  --name metrics-server \
  --namespace ${namespace} \
  --values $dir/values.yaml

wait_for_deployment "metrics-server" ${namespace}