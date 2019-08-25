#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
host=jenkins.$HOST
secretName=${host/\./\-}-crt

source $dir/../functions.sh

helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$host \
  --set master.ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set master.ingress.tls[0].secretName=$secretName \
  --set master.ingress.tls[0].hosts[0]=$host

wait_for_deployment "jenkins" "ci"