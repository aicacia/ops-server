#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

if [[ "${node_type}" == "cluster" ]];
then
  $dir/cert-manager/install.sh
fi

$dir/ingress/install.sh
$dir/docker-registry/install.sh
$dir/chartmuseum/install.sh
$dir/kubernetes-dashboard/install.sh
$dir/jenkins/install.sh