#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=chartmuseum.$HOST
secret_name="${host/\./\-}-crt"

source $dir/../functions.sh

helm install stable/chartmuseum \
  --name chartmuseum \
  --namespace ci \
  --values $dir/values.yaml \
  --set env.secret.BASIC_AUTH_USER=$CHART_USER \
  --set env.secret.BASIC_AUTH_PASS=$CHART_PASS \
  --set ingress.hosts[0].name=$host \
  --set ingress.hosts[0].tls=true \
  --set ingress.hosts[0].tlsSecret=$secret_name \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME

wait_for_deployment "chartmuseum-chartmuseum" "ci"

helm plugin install https://github.com/chartmuseum/helm-push
helm repo add chartmuseum http://$host
helm push --help