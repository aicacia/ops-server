#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=jenkins.$HOST

source $dir/../functions.sh

helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$host

wait_for_deployment "jenkins" "ci"