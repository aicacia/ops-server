#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh
source $dir/../../../.envrc

host="jenkins.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

kubectl apply -f $dir/jenkins-persistent-volume.yaml
kubectl apply -f $dir/jenkins-persistent-volume-claim.yaml

helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$host \
  --set master.ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set master.ingress.tls[0].secretName=$secret_name \
  --set master.ingress.tls[0].hosts[0]=$host

wait_for_deployment "jenkins" "ci"