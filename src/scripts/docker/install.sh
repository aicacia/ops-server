#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=registry.$HOST

source $dir/../functions.sh

helm install stable/docker-registry \
  --name docker-registry \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host

wait_for_deployment "docker-registry" "ci"

echo "add $host to /etc/hosts"