#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=ci

source $dir/../../functions.sh

helm uninstall jenkins -n ${namespace}

kubectl delete -f $dir/jenkins-persistent-volume-claim.yaml -n ${namespace}
kubectl delete -f $dir/jenkins-persistent-volume.yaml -n ${namespace}