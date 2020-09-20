#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cluster_type=$1
user_name=$2

$dir/docker/install.sh ${cluster_type} ${user_name}
$dir/helm/install.sh
$dir/kubeseal/install.sh
$dir/kubernetes/install.sh