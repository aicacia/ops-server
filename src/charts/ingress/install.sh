#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-public
metallb_namespace=metallb-system

source $dir/../../functions.sh

helm install stable/metallb \
  --name metallb \
  --namespace ${metallb_namespace} \
  --values $dir/metallb.yaml \
  --set configInline.address-pools[0].addresses[0]=${API_SERVER_HOST}

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/nginx-ingress \
    --version 1.24.3 \
    --name nginx-ingress \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet
else
  helm install stable/nginx-ingress \
    --version 1.24.3 \
    --name nginx-ingress \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet \
    --set controller.autoscaling.enabled=false
fi

wait_for_deployment "nginx-ingress-default-backend" ${namespace}