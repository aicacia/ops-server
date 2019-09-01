#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

helm delete --purge jenkins

kubectl delete -f $dir/jenkins-persistent-volume-claim.yaml
kubectl delete -f $dir/jenkins-persistent-volume.yaml