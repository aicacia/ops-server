#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kubernetes-dashboard

source $dir/../../functions.sh

kubectl delete -f $dir/default.yaml
kubectl delete -f $dir/cluster_ip_service.yaml
kubectl delete -f $dir/node_port_service.yaml
kubectl delete -f $dir/ingress.yaml