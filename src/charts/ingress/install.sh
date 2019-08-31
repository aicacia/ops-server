#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl_with_environment apply $dir/metallb-config.yaml

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace kube-system \
    --values $dir/values.yaml
else
  helm install stable/nginx-ingress \
    --name nginx-ingress \
    --namespace kube-system \
    --set controller.autoscaling.enabled=false \
    --values $dir/values.yaml
fi

wait_for_deployment "nginx-ingress-controller" "kube-system"