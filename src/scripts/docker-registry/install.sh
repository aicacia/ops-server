#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host="registry.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

source $dir/../init.sh

helm install stable/docker-registry \
  --name docker-registry \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].hosts[0]=$host \
  --set ingress.tls[0].secretName=$secret_name \
  --set secrets.htpasswd=$DOCKER_HTPASSWD

wait_for_deployment "docker-registry" "ci"