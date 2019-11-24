#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=ci

source $dir/../../functions.sh

helm uninstall docker-registry -n ${namespace}

kubectl apply -f $dir/persistent-volume-claim.yaml -n ${namespace}
kubectl apply -f $dir/persistent-volume.yaml -n ${namespace}