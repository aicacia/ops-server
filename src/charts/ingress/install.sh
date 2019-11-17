#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-public
metallb_namespace=metallb-system
version=1.25.0
metalib_version=0.12.0

source $dir/../../functions.sh

kubectl create namespace ${namespace}
kubectl create namespace ${metallb_namespace}

helm install metallb stable/metallb \
  --version ${metalib_version}
  --namespace ${metallb_namespace} \
  --values $dir/metallb.yaml \
  --set configInline.address-pools[0].addresses[0]=${API_SERVER_HOST}

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install nginx-ingress stable/nginx-ingress \
    --version ${version} \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet
else
  helm install nginx-ingress stable/nginx-ingress \
    --version ${version} \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.service.type="" \
    --set controller.kind=DaemonSet \
    --set controller.autoscaling.enabled=false
fi

wait_for_deployment "nginx-ingress-default-backend" ${namespace}