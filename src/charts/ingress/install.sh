#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

kubectl create namespace metallb-system
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl_with_environment apply $dir/metallb.yaml

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace kube-system \
    --values $dir/values.yaml \
    --set controller.service.nodePorts.http=80 \
    --set controller.service.nodePorts.https=443
else
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace kube-system \
    --values $dir/values.yaml \
    --set controller.hostNetwork=true \
    --set controller.autoscaling.enabled=false
fi

wait_for_deployment "nginx-ingress-controller" "kube-system"