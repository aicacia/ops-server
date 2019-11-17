#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kubernetes-dashboard
version=1.10.1

source $dir/../../functions.sh

begin_readme_section "kubernetes-dashboard"

host="dashboard.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

kubectl create namespace ${namespace}

kubectl apply -f $dir/default.yaml

if [[ "${cluster_type}" == "cluster" ]];
then
  kubectl apply -f $dir/cluster_ip_service.yaml
  kubectl apply -f $dir/ingress.yaml
  dashboard_url="https://${host}"
else
  kubectl apply -f $dir/node_port_service.yaml
  dashboard_url=https://localhost:31000
fi

add_to_readme "url: ${dashboard_url}"

wait_for_deployment "kubernetes-dashboard" ${namespace}

kubectl -n ${namespace} describe secret $(kubectl -n ${namespace} get secret | grep kubernetes-dashboard | awk '{print $1}') |
  while IFS= read -r line
  do
    add_to_readme "${line}"
  done

end_readme_section "kubernetes-dashboard"