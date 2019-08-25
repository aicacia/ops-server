#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh
source $dir/../../../.envrc

host="dashboard.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

helm install stable/kubernetes-dashboard \
  --name kubernetes-dashboard \
  --namespace kube-system \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].secretName=$secret_name \
  --set ingress.tls[0].hosts[0]=$host

wait_for_deployment "kubernetes-dashboard" "kube-system"

kubectl -n kube-system describe secrets kubernetes-dashboard-token