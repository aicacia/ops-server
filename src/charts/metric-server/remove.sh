#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-system

source $dir/../../functions.sh

helm uninstall metrics-server -n ${namespace}