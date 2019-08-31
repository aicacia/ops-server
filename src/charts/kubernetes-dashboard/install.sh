#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

begin_readme_section "kubernetes-dashboard"

host="dashboard.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/kubernetes-dashboard \
  --name kubernetes-dashboard \
  --namespace kube-system \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].secretName=$secret_name \
  --set ingress.tls[0].hosts[0]=$host

  dashboard_url="https://${host}"
else
  helm install stable/kubernetes-dashboard \
  --name kubernetes-dashboard \
  --namespace kube-system \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set service.type=NodePort \
  --set service.nodePort=31000

  node_port=$(kubectl get -n kube-system -o jsonpath="{.spec.ports[0].nodePort}" services kubernetes-dashboard)
  dashboard_url=https://localhost:$node_port
fi

add_to_readme "url: ${dashboard_url}"
add_to_readme " "

wait_for_deployment "kubernetes-dashboard" "kube-system"

kubectl -n kube-system describe secrets kubernetes-dashboard-token |
  while IFS= read -r line
  do
    add_to_readme "${line}"
  done

end_readme_section "kubernetes-dashboard"