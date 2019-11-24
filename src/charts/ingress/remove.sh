#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-public
metallb_namespace=metallb-system

source $dir/../../functions.sh

helm uninstall nginx-ingress -n ${namespace}
helm uninstall metallb