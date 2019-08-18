#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=registry.$HOST
secretName=${host/\./\-}-crt

source $dir/../functions.sh

helm install stable/docker-registry \
  --name docker-registry \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].hosts[0]=$host \
  --set ingress.tls[0].secretName=$secretName \
  --set secrets.htpasswd=$DOCKER_HTPASSWD

wait_for_deployment "docker-registry" "ci"