#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=dashboard.$HOST
secretName=${host/\./\-}-crt

source $dir/../functions.sh

helm install stable/kubernetes-dashboard \
  --name kubernetes-dashboard \
  --namespace kube-system \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].secretName=$secretName \
  --set ingress.tls[0].hosts[0]=$host

wait_for_deployment "kubernetes-dashboard" "kube-system"

kubectl -n kube-system describe secrets kubernetes-dashboard-token