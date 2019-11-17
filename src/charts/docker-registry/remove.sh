#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=ci

source $dir/../../functions.sh

helm uninstall docker-registry -n ${namespace}