#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-system
version=2.8.8

source $dir/../../functions.sh

helm install metrics-server stable/metrics-server \
  --version ${version} \
  --namespace ${namespace} \
  --values $dir/values.yaml

wait_for_deployment "metrics-server" ${namespace}