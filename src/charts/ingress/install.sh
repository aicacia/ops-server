#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-public

source $dir/../../functions.sh

kubectl_with_environment apply $dir/metallb.yaml

helm install stable/metallb \
  --name metallb \
  --namespace ${namespace}

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet
else
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet \
    --set controller.autoscaling.enabled=false
fi

wait_for_deployment "nginx-ingress-default-backend" "kube-system"