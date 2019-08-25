#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=chartmuseum.$HOST

source $dir/../functions.sh

helm install stable/chartmuseum \
  --name chartmuseum \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingress.hosts[0].name=$host \
  --set ingress.hosts[0].tls=false \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME

wait_for_deployment "chartmuseum-chartmuseum" "ci"

helm plugin install https://github.com/chartmuseum/helm-push
helm repo add chartmuseum http://$host
helm push --help