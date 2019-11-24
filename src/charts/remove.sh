#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../functions.sh

if [[ "${cluster_type}" == "cluster" ]];
then
  $dir/jenkins/remove.sh ${cluster_name}
  $dir/chartmuseum/remove.sh ${cluster_name}
  $dir/cert-manager/remove.sh ${cluster_name}
fi

$dir/docker-registry/remove.sh ${cluster_name}
$dir/ingress/remove.sh ${cluster_name}
$dir/metric-server/remove.sh ${cluster_name}
$dir/kubernetes-dashboard/remove.sh ${cluster_name}