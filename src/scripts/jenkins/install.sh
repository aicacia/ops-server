#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$HOST

wait_for_deployment "jenkins" "ci"