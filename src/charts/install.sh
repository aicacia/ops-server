#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../functions.sh

if [[ "${cluster_type}" == "cluster" ]];
then
  $dir/cert-manager/install.sh ${cluster_name}
fi

$dir/metric-server/install.sh ${cluster_name}
$dir/ingress/install.sh ${cluster_name}
$dir/docker-registry/install.sh ${cluster_name}
$dir/chartmuseum/install.sh ${cluster_name}
$dir/kubernetes-dashboard/install.sh ${cluster_name}

if [[ "${cluster_type}" == "cluster" ]];
then
  $dir/jenkins/install.sh ${cluster_name}
fi